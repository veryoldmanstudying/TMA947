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
        for gen in node_to_generators[current_node] # The node's own supply, can be multiple generators as in node 2
    )
    return sum_of_generators_in_current_node
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

@constraint(
    the_model,
    [current_node in nodes],
    sum(
        generation[gen]
        for gen in node_to_generators[current_node] # The node's own supply, can be multiple generators as in node 2
    )
    + sum(
        active_power(
            voltage[supplier],
            voltage[recipient],
            phase[supplier],
            phase[recipient],
            bkl_edge_values[(supplier,recipient)],
            gkl_edge_values[(supplier,recipient)]
        )
        for (supplier,recipient) in directed_edges if recipient == current_node # Any external power
    )
    ==
    demand_in_current_node(current_node) # Just return 0 if there is no demand at current node
    + 
    sum(
        active_power(
            voltage[supplier],
            voltage[recipient],
            phase[supplier],
            phase[recipient],
            bkl_edge_values[(supplier,recipient)],
            gkl_edge_values[(supplier,recipient)]
        )
        for (supplier,recipient) in directed_edges if supplier == current_node # Any outgoing power

    )
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

