using JuMP
import Ipopt

include("project_data.jl")
include("functions.jl")

the_model = Model(Ipopt.Optimizer)

@variable(
    the_model,
    voltage[i in nodes],
    lower_bound = voltage_lb,
    upper_bound = voltage_ub
)

@variable(
    the_model,
    phase[i in nodes],
    lower_bound = phase_lb,
    upper_bound = phase_ub,
)

@variable(
    the_model,
    generation[1:n_generators] >= generator_lb
    )


@constraint(
    the_model,
    [i=1:n_generators],
    generator_lb <= generation[i] <= generator_ub[i]
)

# Main logic is defined here. 
# Some sanity checks - if internal generation is 0 and demand is non-zero, then
# outgoing power will be 0 and incoming power will be equal to demand for a feasible solution 
@constraint(
    the_model,
    [current_node in nodes],

    internal_generation_current_node(current_node) # Just returns 0 if there is no generation at current node
     + 
    incoming_power_to_current_node(current_node)
    ==
    demand_in_current_node(current_node) # Just returns 0 if there is no demand at current node
    + 
    outgoing_power_from_current_node(current_node)
)

@variable(
    the_model,
    reactive_generation[1:n_generators] # Only generators are capable of absorbing or generating reactive power
)
@constraint(
    the_model,
    [i=1:n_generators],
    min_reactive_scalar*generator_ub[i] <= reactive_generation[i] <= max_reactive_scalar*generator_ub[i]
)

@objective(
    the_model,
    Min,
    sum(
        generator_costs[i]*generation[i]
        for i in 1:n_generators
    ),
)

println(the_model)
optimize!(the_model)


println("Optimal generation:")
println(value.(generation))
println("Optimal phase:")
println(value.(phase))
println("Optimal voltage:")

println(value.(voltage))


# Some other sanity checks now that decision variables have been created. Can for instance list power flows from the definition of 
# active power, looping over nodes.
