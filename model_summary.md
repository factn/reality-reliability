### Agents and claims

We consider problems involving a collection of agents making claims where we want to jointly infer the **accuracy** of those claims as well as the **reliability** of the agents. 

Getting reliable information from a network of (potentially) unreliable agents is a problem with applications in crowdsourcing, collective intelligence, loan allocation, disaster response and intelligence, targeting of aid, and many other areas. 

In some of these contexts it also useful to be able to estimate, in a principled way, the number of bits of useful information contained in a message so that the most **important** claims can be processed first.

We consider a collection of agents <a href="http://mathurl.com/ybr85kd7"><img src="http://mathurl.com/ybr85kd7.png" /></a> and a set of claims <a href="http://mathurl.com/ybccx4nt"><img src="http://mathurl.com/ybccx4nt.png"></a>. Each claim has three parts:
 - an _*index*_, i (what the claim is about)
 - a _*signature*_, a (the agent which makes this claim)
 - a _*value*_, x (a numeric, or categorical, measurement)

Examples of claims :
- That the barometric pressure at index i, (lat, lng, time), has value, x, as measured by the given weather gauge, a
- That an agent will not default on a specified loan, i, as claimed (promised) by that agent, a
- That an agent, b, has a probability of default, x, on a specified loan i, as estimated by another agent, a
- That the bridge at location i is 'at risk of overtopping', as observed by agent a 
- That in a claim made by an agent b, being generally consistent with other valid information held by agent a, has a validity, x as estimated by that agent

We also aim to ascribe a property _*validity*_ to all claims, where <a href="http://mathurl.com/yd86scj5"><img src="http://mathurl.com/yd86scj5.png"></a>. In the case of claims about measurable reality we define this as the probability that an 'objective measurement' made at index i will return (or would have returned) the same value, x as in the claim. 

<a href="http://mathurl.com/y7prd9y9"><img src="http://mathurl.com/y7prd9y9.png"></a>

As we shall see, it is not always necessary to directly measure v in order to be able to usefully reason with it, as we can sometimes infer it's value from data.


### World model, agent model, measurement model 

In the general case, claims are independent and such inference, as described above, is impossible. However, for specific domains where we can build (or assume) models that constrain the degrees of freedom, some useful inference is possible. Such constraints generally fall into three areas:
- *world model*
- *agent model*
- *measurement model*

The **world model** is domain specific and describes how claims made at one index relate to claims made at another index. For example, if we index weather gauge measurements by <lat, long, time> a simple world model might simply note that weather measurements tend to be correlated in time and space w,hereas a more complex world model might take into account the tendency for weather patterns to evolve over time in specific ways. Either way, the model can be used to spot measurements at one gauage that are inconsistent with a bulk of data from other 'nearby' gauges.

The **agent model** describes how the validity of claims made by one agent relate to the validity of claims made by that same agent. 

Consider the case outlined in the 2012 paper from Bachrach, Yoram, et al. ["How to grade a test without knowing the answers --- a Bayesian graphical model for adaptive crowdsourcing and aptitude testing."](https://icml.cc/2012/papers/597.pdf). To adapt our model to this paper, we would consider agents to be students taking a test, the index to be the number of the question in the test, and x to be the answer given by that student to that question. Validity is just whether or not an answer is correct. In this paper it is assumed that agents (students) have a single latent variable measuring the aptitude of that student. In fact, it goes further to assume that students tend to cluster into types, where the latent variable for aptitude on a given question, is shared by all students of that type.

The **measurement model** describes how the measurement, x, for a given agent at a given index is distributed. 

For example, in the aptitude testing question above they assume there is a latent variable measureing how 'hard' each question is which also affects the validity of answers given to questions. As another example, if measuring the income in a given suburb, we might ask five randomly chosen household what their income is. We would expect this to be approximate to the mean for that suburb, but the measurement model would describe how much variance we would expect in the variance, given the method used. 

We have begun some simple experiments and been able to demonstrate, given model constraints for a specific domain, that we can use graphical/bayesian modeling, to predict the agent reliability as well the claim accuracy in a principled way from observed data.

Furthermore, we can measure the likelihood of a claim as a proxy for message 'importance'. For instance, given a basic agent model (assuming bias and accuracy as latent variables per agent), then an otherwise suprising claim (per the world model) from a reliable source (per the agent model) has a low likelihood and therefore should be considered 'important'. (Suprising claims from unreliable sources actually have a medium to high likelihood and are therefore not considered to contain so much information).

In general we hope that given a stream of messages and appropriate world, agent and measurement models we can provide the following outputs in a general way.

<a href="https://creately.com/diagram/jo3gw9302/eyvMFJw8XXJiDfHzUILp2upUQg%3D"><img src="estimated_model.png" /></a>

### Networks of agents (channeled communication)

So far, we have assumed a 'god view' where we have access to all claims from all agents. 

In practice however we may only be connected to a limited number of agents. Therefore it may be preferable to consider 'ourself' as part of the network - as just one more agent within a network where each agent as performing these kind of evaluations on messages received from other agents and then preferentialy emitting important, valid messages. In such a case we can consider the entropy of the system as a whole. Early experiments suggest when the 'reality' is held fixd, the messages sent by the network of agents eventually settles to a low-entropy equilibrium with low activity, jumping to a high activity as soon as the underlying reality changes and measurements therefore become low likelihood.

We also wish to explore how resistant such a network is to 'rogue' agents who, whether through malice or incompetance, tend to emit claims of low validity, and how we can refine the agent and world models to make the overall network more resistant to such attacks.

### Some example domains (TBC)

**The waggle dance**

- Agent model = bees are trustworthy
- World model = flowers have pollen at specific locations
- Measurement model = the waggle dance is used to communicate where the pollen is at

**Self grading test / crowd sourcing generally**

- Agent model = student aptitude
- World model = null (no correlation between questions)
- Measurement model = some questions are harder than others

**Claims about claims**

- Agent a says they attended meeting
- Agent b confirms what agent a says 
- World model - agents can't confirm a meeting attendance if they were not there themselves
- ...
- ...


### Appendix 

[1] In general we would want to define a 'validity' measure across a wide range of claim types:
- Claims about an objective, measurable reality 
- Promises or commitments (to be undertaken in the future)
- Claims about validity of other claims
- Claims about subjective reality 

