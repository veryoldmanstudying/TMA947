# constraints shared across all individual variables
voltage_lb = 0.98
voltage_ub = 1.02

radian_lb = -pi
radian_ub = pi

# Representing the edges 
edges = [
    (1,2),
    (1,11),
    (2,3),
    (2,11),
    (3,4),
    (3,9),
    (4,5),
    (5,6),
    (5,8),
    (6,7),
    (7,8),
    (7,9),
    (8,9),
    (9,10),
    (10,11)
]

# Make sure it is bidirectional
directed_edges = [
    (k, l) for (k, l) in edges
]

append!(
    directed_edges,
    [(l, k) for (k, l) in edges]
)

    

bkl_edge_values = Dict(
    (1,2) => -20.1,
    (1,11) => -22.3,
    (2,3) => -16.8,
    (2,11) => -17.2,
    (3,4) => -11.7,
    (3,9) => -19.4,
    (4,5) => -10.8,
    (5,6) => -12.3,
    (5,8) => -9.2,
    (6,7) => -13.9,
    (7,8) => -8.7,
    (7,9) => -11.3,
    (8,9) => -7.7,
    (9,10) => -13.5,
    (10,11) => -26.7
)

# Make it bidirectional, can't hurt
for ((k, l), value) in collect(bkl_edge_values)
    bkl_edge_values[(l, k)] = value
end


# bkl dict with edges since tuples should be immutable in Julia
gkl_edge_values = Dict(
    (1,2) => 4.12,
    (1,11) => 5.67,
    (2,3) => 2.41,
    (2,11) => 2.78,
    (3,4) => 1.98,
    (3,9) => 3.23,
    (4,5) => 1.59,
    (5,6) => 1.71,
    (5,8) => 1.26,
    (6,7) => 1.11,
    (7,8) => 1.32,
    (7,9) => 2.01,
    (8,9) => 4.41,
    (9,10) => 2.14,
    (10,11) => 5.06
)
# Make it bidirectional too!

for ((k, l), value) in collect(gkl_edge_values)
    gkl_edge_values[(l, k)] = value
end


# List which generator points to which node. They should only reside in one. 

generator_number_to_node = Dict(
    1 => 2, # These all live in the same node
    2 => 2,
    3 => 2,
    4 => 3,
    5 => 4,
    6 => 5,
    7 => 7,
    8 => 9,
    9 => 9
)

# Continue tomorrow
consumer_number_to_node = Dict(
    


)

consumer_lb = [
    c1_lb,
    c2_lb,
    c3_lb,
    c4_lb,
    c5_lb,
    c6_lb,
    c7_lb,
]

# Generator upper bounds
g1_ub = 0.02
g2_ub = 0.15
g3_ub = 0.08
g4_ub = 0.07
g5_ub = 0.04
g6_ub = 0.17
g7_ub = 0.17
g8_ub = 0.26
g9_ub = 0.05

generator_ub = [
    g1_ub,
    g2_ub,
    g3_ub,
    g4_ub,
    g5_ub,
    g6_ub,
    g7_ub,
    g8_ub,
    g9_ub
]

# Costs
g1_cost = 175
g2_cost = 100
g3_cost = 150
g4_cost = 150
g5_cost = 300
g6_cost = 350
g7_cost = 400
g8_cost = 300
g9_cost = 200

generator_costs = [
    g1_cost,
    g2_cost,
    g3_cost,
    g4_cost,
    g5_cost,
    g6_cost,
    g7_cost,
    g8_cost,
    g9_cost,
]

