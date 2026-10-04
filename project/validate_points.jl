import JSON

include("functions.jl")
include("project_data.jl")

filename = "feasible_points.json"
global tolerance = 1e-7

within_bounds(value, lb, ub) = lb - tolerance <= value <= ub + tolerance

check_voltage_bounds(voltage) = all(within_bounds(voltage[i], voltage_lb, voltage_ub) for i in nodes)

check_phase_bounds(phase) = all(within_bounds(phase[i], phase_lb, phase_ub) for i in nodes)

check_generation_bounds(generation) = all(
    within_bounds(generation[i], generator_lb, generator_ub[i]) for i in 1:n_generators
)

check_reactive_generation_bounds(reactive_generation) = all(
    within_bounds(reactive_generation[i], min_reactive_scalar * generator_ub[i], max_reactive_scalar * generator_ub[i])
    for i in 1:n_generators
)

check_objective(objective_value, generation) = abs(sum(generator_costs .* generation) - objective_value) <= tolerance

function validate_point(point)
    voltage = Float64.(point["voltage"])
    if check_voltage_bounds(voltage) == false
        println("Voltage bound failure")
        return false
    end
    generation = Float64.(point["generation"])
    
    if check_generation_bounds(generation) == false
        println("Generation bound failure")
        return false
    end

    reactive_generation = Float64.(point["reactive_generation"])
    check_reactive_generation_bounds(reactive_generation)
    
    if check_reactive_generation_bounds(reactive_generation) == false
        println("Reactive generation bound failure")
        return false
    end
    phase = Float64.(point["phase"])
    if check_phase_bounds(phase) == false
        println("Phase bound failure")
        return false
    end
    objective = Float64.(point["objective"])
    if check_objective(objective, generation) == false
        println("Inconsistent objective value")
        return false

    end


    return true
end

data = JSON.parse(read(filename, String))

for (i, sample) in enumerate(data["samples"])
    if validate_point(sample) == true
        println("Sample $i valid")
        generation = Float64.(sample["generation"])
        objective_value = sum(generator_costs .* generation)
        println("Objective value: $objective_value")
    else println("Sample $i infeasible")
    end
end