# constraints shared across all individual variables
voltage_lb = 0.98
voltage_ub = 1.02

phase_lb = -pi
phase_ub = pi

generator_lb = 0 # Non-negative

# Enumeration of nodes, generators, consumers
nodes = 1:11
println(nodes)
n_nodes = length(nodes)
n_generators = 9
n_consumers = 7


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
generator_to_node = Dict(
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
# Also define the reverse mapping so we can get the one-to-many relationship
node_to_generators = Dict(
    node => [g for (g,n) in generator_to_node if n == node]
    for node in nodes
)

println(generator_to_node)
println(node_to_generators)

# Consumers also just reside in one node, but multiple consumers are never present in one node
consumer_to_node = Dict(
    1 => 1,
    2 => 4,
    3 => 6,
    4 => 8,
    5 => 9,
    6 => 10,
    7 => 11
)

node_to_consumer = Dict(
    1 => 1,
    4 => 2,
    6 => 3,
    8 => 4,
    9 => 5,
    10 => 6,
    11 => 7
)

# Consumer demand lower bound(?) Might be equality constraint later.
consumer_demand_lb = [
    0.10,
    0.19,
    0.11,
    0.09,
    0.21,
    0.05,
    0.04,
]

node_to_demand = Dict(
    1 => 0.10,
    4 => 0.19,
    6 => 0.11,
    8 => 0.09,
    9 => 0.21,
    10 => 0.05,
    11 => 0.04
)

# Generator upper bounds

generator_ub = [
    0.02,
    0.15,
    0.08,
    0.07,
    0.04,
    0.17,
    0.17,
    0.26,
    0.05
]

# Generator costs per unit of power

generator_costs = [
    175,
    100,
    150,
    150,
    300,
    350,
    400,
    300,
    200,
]

