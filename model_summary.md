We consider problems involving a collection of agents making claims where we want to jointly infer the accuracy of those claims as well as the reliability of the agents. 

Getting reliable information from a network of (potentially) unreliable agents is a problem with applications in crowdsourcing, collective intelligence, loan allocation, disaster response and intelligence, targeting of aid, and many other areas. In some of these contexts it also useful to be able to flag, in a principled ways, the claims containing the most bits of useful information so that they can be processed first.

We consider a collection of agents <a href="http://mathurl.com/ybr85kd7"><img src="http://mathurl.com/ybr85kd7.png" /></a> and a set of claims <a href="http://mathurl.com/ybccx4nt"><img src="http://mathurl.com/ybccx4nt.png"></a>. Each claim has three parts:
 - an index, i (what the claim is about)
 - a signature, a (fom the agent which makes this claim)
 - a value, x (the numeric, or categorical, measurement)

Examples of claims might be :
- That the barometric pressure at (lat, lng, time) index i, has value, x, as measured by the weather gauge, a
- That an agent will not default on a specified loan, i, as claimed (promised) by that agent, a
- That an agent b has a probability of default, x, on a specified loan i, as estimated by another agent, a
- That the bridge at location i is 'at risk of overtopping', as observed by agent a 
- That in general, claims made by agent b, being generally consistent with other information held by agent a, have an average validity x

We define a property of claims called **validity** where <a href="http://mathurl.com/yd86scj5"><img src="http://mathurl.com/yd86scj5.png"></a>. In the case of claims about measurable reality we define this to be the probability that an 'objective measurement' made at index i will return (or would have returned) the same value, x as in the claim. As we shall see, it is not always necessary to directly measure v in order to be able to usefully reason with it as we can sometimes infer it's value from data [1]
<a href="http://mathurl.com/y7prd9y9"><img src="http://mathurl.com/y7prd9y9.png"></a>

In the general case claims are independent and such inference is impossible, but for specific domains where we can build (or assume) models that constrain the degrees of freedom, some useful inference is possible. 

We 

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

[1] In general we would want to define a 'validity' measure across a wide range of claim types:
- Claims about an objective, measurable reality 
- Promises or commitments (to be undertaken in the future)
- Claims about validity of other claims
- Claims about subjective reality 

