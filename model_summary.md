We consider problems involving a collection of agents making claims where we want to infer both the accuracy of those claims as well as the reliability of the agents. We also wish to flag the claims containing the most bits of information so they can be processed first.

Getting reliable and/or useful information from a network of (potentially) unreliable agents is a problem with applications in crowdsourcing, collective intelligence, loan allocation, disaster response and intelligence, targeting of aid, and many other areas.

We consider a collection of agents A = {ai} and a set of claims C = { (a,i,x) } where each claim has three parts:
 - an index, i (what the claim is about)
 - a signature, a (fom the agent which makes this claim)
 - a value, x (the numeric, or categorical, measurement)

Examples of claims might be :
- That the barometric pressure at location/time, i, is x, as measured by weather gauge, a
- That agent a will not default on a specified loan, i, as claimed (promised) by agent a
- That agent a has a probability of default x on a specified loan i, as measured by another agent b
- That the bridge at location i is 'at risk' of overtopping, x, as observed by agent a 
- That a student (agent) a, gives the answer x, to the question i on the test
- That a claim made by agent b, is consistent with other information held by agent a, who estimates it to be a valid claim with probability x

In the general case claims are independent but for specific domains we can build models to constrain the domain in various ways.

A 'world model' says that claims made about a given thing will be related according to some model. 
''latex for all i (i, a) <-> (i, b) and 
'' and (i, a) <-> (j, b) regardless of a and b

 
<math>
<img src="https://latex.codecogs.com/gif.latex?E=mc^2" />
 
<img src="https://latex.codecogs.com/gif.latex?x%20%3D%20a_0%20&plus;%20%5Cfrac%7B1%7D%7Ba_1%20&plus;%20%5Cfrac%7B1%7D%7Ba_2%20&plus;%20%5Cfrac%7B1%7D%7Ba_3%20&plus;%20a_4%7D%7D%7D" />


For example, if we index weather gauge measurements by (lat, long, time) the model would state that measurements would be correlated in time and space. A simple 'world model' for this case would simply state that correlation is expected to be higher the closer the index. More complex 'world models' may take into account global weather and be able to spot measurements that are inconsistent with a pattern from other gauges.

Furthermore if we assume that the validity and bias of claims made by a given agent are correlated we can use this to infer a latent variable for the bias and accuracy of all agents (given an observed set of claims) without being able to independently measure the underlying validity of the claims.  

*Agent model*

An 'agent model' constrains from the same agent or related agents.
''latex for all agents a, (i, a) <-> (j, a)

For example, we might assume that in a given domain an agent has a latent bias and variance across all claims by that agent are drawn. As another example, in the paper from Bachrach, Yoram, et al. ["How to grade a test without knowing the answers---a Bayesian graphical model for adaptive crowdsourcing and aptitude testing." (2012)](https://icml.cc/2012/papers/597.pdf) they assume that agents come from a class, and that the precision of each agent on a test is constrained by the class of that agent. 

*Value model*

A 'value model' or is it a measurement model, lets us.. uhm what? Eek. 
''' latex for all a, i, (i,a) <-> (i,a) ?

As an example we assume that some questions are harder than others, and thus the accuracy of answers to the test for those questions is less than for other questions.

When we provide these three inputs to our model we can then use bayesian modeling, to predict the agent reliability as well as to estimate the reality in a principled way from multiple cases. 

Furthermore, we can measure the likelihood of each new claim. In a realtime scenario a suprising claim from a reliable source would have a low likelihood and should therefore be flagged as important. (Suprising claims from unreliable sources would have reasonable likelihood and are therefore not important).

<a href="https://creately.com/diagram/jo3gw9302/eyvMFJw8XXJiDfHzUILp2upUQg%3D"><img src="estimated_model.png" /></a>
