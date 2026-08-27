# TMA947
Non linear optimization

Idea - skip the weird reactive power for now and solve without taking that one into consideration. 

Current questions:
- Is the demand in each consumer a lower bound or an equality constraint?
- If it is a lower bound, what happens with excess energy?
- How to interpret/deal with reactive power? 
- Reference angle (we actually only care about the diff )

**Core assumptions** 
Phase theta_l, theta_k are on defined node level, not generator level. So multiple generators residing in one node
can not have different phases.

A generator can only supply it's own node or an adjacent one as defined by the edges. This is assumed since otherwise the modelling seems to become a bit harder and I don't like my brain to hurt.



**Arbitrary philosophy**
Constraints, conceptually:
Local generation + incoming power = local demand + outgoing power

Extreme cases:
If local generation is the most cost-effective choice, even for supplying other nodes, then the full local demand should be attempted to be met by the local generation. Any surplus is sent to adjacent nodes _if_ it is indeed the most cost effective choice.

If it is not enough (local generation < local demand) and local generation is the most cost effective, then the delta must be supplied from another node, leaving no outgoing power.

If local generation is the most costly, it will be zero - provided that other generators can supply it without exceeding their max capacity.