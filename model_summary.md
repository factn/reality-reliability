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

<a href="http://mathurl.com/yc4cfkcg"><img src="http://mathurl.com/yc4cfkcg.png"></a>

As we shall see, it is not always necessary to directly measure v in order to be able to usefully reason with it, as we can sometimes infer it's value from data.


### World model, agent model, measurement model 

In the general case, claims are independent and such inference as described above is impossible. However, for domains where we can build (or assume) models that constrain the degrees of freedom, some useful inference is possible. Such constraints generally fall into three areas:
- *world model*
- *agent model*
- *measurement model*

A **world model** is domain specific and describes how claims made at one index relate to claims made at another index. For example, if  weather gauge measurements are indexed by <lat, long, time> a simple world model might simply note that nearby measurements tend to be similar. A more complex world model might take into account the full complexity of weather patterns and their tendency to move across space and time in various ways. Whether complex or simple the world model can be used to spot measurements at one gauage that are inconsistent with the bulk of data from other 'nearby' gauges. Such inconsistent measurements are said to be 'suprising'.

An **agent model** describes how the claims made by an agent tend to be distributed.

For example in [Bachrach, Yoram, et al. "How to grade a test without knowing the answers---a Bayesian graphical model for adaptive crowdsourcing and aptitude testing." (2012).](https://icml.cc/2012/papers/597.pdf) they describe a bayesian model with a latent variable called 'ability' attached to each student. To adapt our model to this scenario, we might consider agents to be the students taking the test, the index to be the question asked, the value, x, to be the answer given by the student and validity to be whether or not the answer was correct. In this case, ability creates a fixed variance or accuracy over student answers. Some agent models ascribe a latent precision as well as accuracy term to agents. More complex agent models may group agents into classes such as in [Venanzi, Matteo, et al. "Community-based bayesian aggregation models for crowdsourcing." Proceedings of the 23rd international conference on World wide web. ACM, 2014](https://dl.acm.org/citation.cfm?id=2567989)

A **measurement model** describes how the measurement, x, for a given agent given a particular index is distributed. 

In the aptitude testing scenario described above they assume there is a latent variable measureing how 'hard' each question is which also affects the validity of answers given to questions. It might also be that a weather gauge has a given accuracy. As another example, if measuring the income in a given suburb, we might ask five randomly chosen households what their income and expect a variance around the true mean depending on suburb. 

--

As the above papers demonstrate, when you constrain the domain it is possible to infer the correct answer in a way that is more principled than a simple average. We have also been able to demonstrate, given model constraints for a simple domain, that we can use graphical/bayesian modeling to predict the agent reliability as well the claim accuracy in a principled way from observed data.

Furthermore, we can measure the log likelihood of a claim as a proxy for the 'importance' of that message. For instance, given a basic agent model, an otherwise suprising claim from a reliable source has a low likelihood and therefore should be considered 'important'. By  contrast, suprising claims (per the world model) from unreliable sources have a higher likelihood and can therefore be considered to contain fewer bits of information and be less important.

We hope to build a general model that, given a stream of messages as well as an appropriate world, agent and measurement models can provide the following outputs in a general way.

<a href="https://creately.com/diagram/jo3gw9302/eyvMFJw8XXJiDfHzUILp2upUQg%3D"><img src="estimated_model.png" /></a>

### Networks of agents (channeled communication)

So far, we have assumed a 'god view' where we have access to all claims from all agents. In practice, however, we may only be connected to a limited number of agents. 

For various reasons we believe it may be useful to consider a network of agents where every agent is performing these kind of evaluations on the messages received from other agents and then preferentialy emitting what they consider to be important, valid messages. Each agent may also be initiating measurements or claims. In such a case we can consider the entropy of the system as a whole.

Early investigations suggest that when the 'reality' is held fixed, the messages sent by the network of agents eventually settles to a low-entropy equilibrium with low activity, but jumps to a high activity as soon as the underlying reality changes and measurements become low likelihood.

We also wish to explore how resistant such a network would be to 'rogue' agents who, whether through malice or incompetance, tend to emit claims of low validity, and how we can refine the agent and world models to make the overall network more resistant to such attacks.

### Some example domains 

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

In general we would want to define a 'validity' measure across a wide range of claim types:
- Claims about an objective, measurable reality 
- Promises or commitments (to be undertaken in the future)
- Claims about validity of other claims
- Claims about subjective reality 

