# TMA947
Non linear optimization

Current questions:
- Is the demand in each consumer a lower bound or an equality constraint? Modelling as equality constraint for now.

**Core assumptions** 
Phase theta_l, theta_k are on defined node level, not generator level. So multiple generators residing in one node
can not have different phases. Makes sense if you think of it as the transmission line being the interface to each node. Besides, the coefficients are defined on node level, not generator level. Case closed?

A generator can only supply it's own node or an adjacent one as defined by the edges. This is assumed since otherwise the modelling seems to become a bit harder and I don't like my brain to hurt.


**Arbitrary philosophy**
Constraints, conceptually:
Local generation + incoming power = local demand + outgoing power

Extreme cases:
If local generation is the most cost-effective choice, even for supplying other nodes, then the full local demand should be attempted to be met by the local generation. Any surplus is sent to adjacent nodes _if_ it is indeed the most cost effective choice.

If it is not enough (local generation < local demand) and local generation is the most cost effective, then the delta must be supplied from another node, leaving no outgoing power.

If local generation is the most costly, it will be zero - provided that other generators can supply it without exceeding their max capacity.

TODO:
- Validate sum of generated reactive power is equal to the sum of absorbed reactive power. Otherwise the system is ever increasing or decreasing in power.
- Validate that sums of outgoing power from each generator (sum of active power functions from the relevant edges) equals that of the decision variable. Otherwise something is seriously messed up.
- Validate that reactive power constraint is working as intended. It added very little change to the model after it was introduced.
- Create generator -> consumer ribbon diagram or similar for project visualization
- Create bar diagram for each generator that shows how big fraction of total operational power is used. Maybe keep it normalized. Maybe don't keep it normalized.
- (Optional) - Run a long generation of random feasible solutions with same constraints, store in json or whatever and 
