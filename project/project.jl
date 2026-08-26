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

function reactive_power(
    voltage_k,
    voltage_l,
    phase_k,
    phase_l,
    b_kl,
    g_kl)

    return -voltage_k^2*b_kl + voltage_k*voltage_l(b_kl*cos(phase_k - phase_l) - g_kl*sin(phase_k - phase_l))
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


@variable(the_model, generation[1:n_generators] >= generator_lb)
@constraint(
    the_model,
    [i=1:9],
    generator_lb <= generation[i] <= generator_ub[i]
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

