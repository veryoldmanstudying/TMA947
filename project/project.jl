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

@variable()

the_model = Model(Ipopt.Optimizer)
lb = 0
@variable(
    the_model,
    x[1:2, 1:2] >= lb,
)


@variable(the_model, generation[1:9] >= 0)
@constraint(
    the_model,
    [i=1:9],
    generation[i] <= generator_ub[i]
)


@objective(
    the_model,
    Min,
    sum(
        (x[i, j] - 2)^2
        for i in 1:n_vars_first_dimension, j in 1:n_vars_second_dimension
    ),
)

println(the_model)
optimize!(the_model)
println("Optimal point: ", value.(x))


