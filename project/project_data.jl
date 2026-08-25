voltage_lb = 0.98
voltage_ub = 1.02

radian_lb = -pi
radian_ub = pi

# bkl data 
b1_2 = -20.1
b1_11 = -22.3
b2_3 = -16.8
b2_11 = -17.2
b3_4 = -11.7
b3_9 = -19.4
b4_5 = -10.8
b5_6 = -12.3
b5_8 = -9.2
b6_7 = -13.9
b7_8 = -8.7
b7_9 = -11.3
b8_9 = -7.7
b9_10 = -13.5
b10_11 = -26.7

#gkl
g1_2 = 4.12
g1_11 = 5.67
g2_3 = 2.41
g2_11 = 2.78
g3_4 = 1.98
g3_9 = 3.23
g4_5 = 1.59
g5_6 = 1.71
g5_8 = 1.26
g6_7 = 1.11
g7_8 = 1.32
g7_9 = 2.01
g8_9 = 4.41
g9_10 = 2.14
g10_11 = 5.06

# Consumer lower bounds
c1_lb = 0.1
c2_lb = 0.19
c3_lb = 0.11
c4_lb = 0.09
c5_lb = 0.21
c6_lb = 0.05
c7_lb = 0.04

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

