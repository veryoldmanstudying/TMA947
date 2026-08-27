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

function incoming_power_to_current_node(current_node)
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

function outgoing_power_from_current_node(current_node)
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
