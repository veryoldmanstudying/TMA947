# Disclosure - AI generated to generate feasible points in between the measured optimal and least optimal solutions
# Used to generate points for graph showcasing objective values for random feasible points.


# Sampling of random (unoptimized) feasible points, to compare against the optimal objective value.
# The feasible set is defined by nonlinear equality constraints, so a point drawn uniformly within the
# variable bounds is almost surely infeasible. Instead we draw a random target point within the bounds
# and let Ipopt find a feasible point close to it (a projection onto the feasible set). The objective
# value is then evaluated at that feasible point.
#
# Runs project.jl first to build and solve the model, then samples feasible points and saves them
# together with the optimal point to feasible_points.json (checked by validate_points.jl).
#
# Usage: julia sampling.jl

include("project.jl")

using Random
import JSON

# Squared distance from the target, each term scaled by the variable's range so that voltage
# (range 0.04) and phase (range 2pi) weigh equally. Variables with zero range are fixed by their
# bounds anyway, so they are skipped.
function scaled_squared_distance(variable, target, lb, ub)
    range = ub - lb
    return range > 0 ? ((variable - target) / range)^2 : 0.0
end

function random_in_bounds(lb, ub)
    return lb + rand() * (ub - lb)
end

function generation_cost(generation_values)
    return sum(generator_costs[i] * generation_values[i] for i in 1:n_generators)
end

function sample_feasible_point(; seed = nothing)
    if seed !== nothing
        Random.seed!(seed)
    end

    distance_terms = []

    for i in nodes
        target = random_in_bounds(voltage_lb, voltage_ub)
        set_start_value(voltage[i], target)
        push!(distance_terms, scaled_squared_distance(voltage[i], target, voltage_lb, voltage_ub))

        target = random_in_bounds(phase_lb, phase_ub)
        set_start_value(phase[i], target)
        push!(distance_terms, scaled_squared_distance(phase[i], target, phase_lb, phase_ub))
    end

    for i in 1:n_generators
        target = random_in_bounds(generator_lb, generator_ub[i])
        set_start_value(generation[i], target)
        push!(distance_terms, scaled_squared_distance(generation[i], target, generator_lb, generator_ub[i]))

        reactive_lb = min_reactive_scalar * generator_ub[i]
        reactive_ub = max_reactive_scalar * generator_ub[i]
        target = random_in_bounds(reactive_lb, reactive_ub)
        set_start_value(reactive_generation[i], target)
        push!(distance_terms, scaled_squared_distance(reactive_generation[i], target, reactive_lb, reactive_ub))
    end

    @objective(the_model, Min, sum(distance_terms))
    optimize!(the_model)

    if !is_solved_and_feasible(the_model)
        return nothing
    end

    return current_point()
end

# The decision variable values currently held by the model, as plain vectors indexed like the variables
function current_point()
    return Dict(
        "objective" => generation_cost(value.(generation)),
        "generation" => [value(generation[i]) for i in 1:n_generators],
        "reactive_generation" => [value(reactive_generation[i]) for i in 1:n_generators],
        "voltage" => [value(voltage[i]) for i in nodes],
        "phase" => [value(phase[i]) for i in nodes],
    )
end

function save_points_json(filename, optimal_point, samples)
    open(filename, "w") do file
        JSON.json(file, Dict("optimal" => optimal_point, "samples" => samples); pretty = true)
    end
end

# Draws n_samples feasible points. Restores the original objective afterwards, but note that
# the model's variable values will be those of the last sample, so read off the optimal solution first.
function sample_feasible_points(n_samples; seed = nothing)
    if seed !== nothing
        Random.seed!(seed)
    end

    original_objective = objective_function(the_model)
    original_sense = objective_sense(the_model)
    was_silent = get_attribute(the_model, MOI.Silent())
    set_silent(the_model)

    samples = []
    n_failed = 0
    try
        for _ in 1:n_samples
            sample = sample_feasible_point()
            if sample === nothing
                n_failed += 1
            else
                push!(samples, sample)
            end
        end
    finally
        set_objective(the_model, original_sense, original_objective)
        if !was_silent
            unset_silent(the_model)
        end
    end

    return samples, n_failed
end

optimal_point = current_point()
# Most random targets end up locally infeasible, so keep sampling until enough feasible points are found
n_wanted = 100
max_attempts = 300
samples = []
n_attempts = 0
while length(samples) < n_wanted && n_attempts < max_attempts
    new_samples, n_failed = sample_feasible_points(n_wanted - length(samples))
    append!(samples, new_samples)
    global n_attempts += length(new_samples) + n_failed
end
println("Sampled ", length(samples), " feasible points in ", n_attempts, " attempts")
save_points_json("feasible_points.json", optimal_point, samples)
