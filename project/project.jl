using JuMP
import Ipopt

include("project_data.jl")

function active_power(
    voltage_k,
    voltage_l,
    phase_k,
    phase_l,
    b_kl,
    g_kl)
    return voltage_k^2*g_kl - voltage_k*voltage_l*(g_kl*cos(phase_k - phase_l) - b_kl*sin(phase_k - phase_l))
end

# Figure out what to do with this
function reactive_power(
    voltage_k,
    voltage_l,
    phase_k,
    phase_l,
    b_kl,
    g_kl)

    return -voltage_k^2*b_kl + voltage_k*voltage_l(b_kl*cos(phase_k - phase_l) - g_kl*sin(phase_k - phase_l))
end

function internal_generation_current_node(current_node)
    sum_of_generators_in_current_node = sum(
        generation[gen]
        for gen in node_to_generators[current_node]; # The node's own supply, can be multiple generators as in node 2
        init = 0 # Seems to be needed for handling ArgumentError: reducing over an empty collection is not allowed; consider supplying `init` to the reducer
    )
    return sum_of_generators_in_current_node
end

function incoming_power_from_other_suppliers(current_node)
    sum_of_incoming_power_from_other_suppliers = sum(
        active_power(
            voltage[supplier],
            voltage[recipient],
            phase[supplier],
            phase[recipient],
            bkl_edge_values[(supplier, recipient)],
            gkl_edge_values[(supplier, recipient)]

        ) for (supplier, recipient) in directed_edges if recipient == current_node;
        init = 0
    )
    return sum_of_incoming_power_from_other_suppliers
end

function outgoing_power_to_recipients(current_node)
    sum_of_outgoing_power_to_recipients = sum(
                active_power(
            voltage[supplier],
            voltage[recipient],
            phase[supplier],
            phase[recipient],
            bkl_edge_values[(supplier, recipient)],
            gkl_edge_values[(supplier, recipient)]
    ) for (supplier, recipient) in directed_edges if supplier == current_node;
    init = 0
    )
    return sum_of_outgoing_power_to_recipients
end

function demand_in_current_node(current_node)
    return get(node_to_demand, current_node, 0)
end


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

    internal_generation_current_node(current_node)
     + 
    incoming_power_from_other_suppliers(current_node)
    ==
    demand_in_current_node(current_node) # Just return 0 if there is no demand at current node
    + 
    outgoing_power_to_recipients(current_node)
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