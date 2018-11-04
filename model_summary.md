We aim to model a collection of agents making various claims and infer the accuracy of those claims as well as the reliability of those agents.

Each claim carries three parts:
 - an index (what the claim is about)
 - a signature (which agent makes this claim)
 - a value (the numeric, or categorical, measurement)
 
<math>
<img src="https://latex.codecogs.com/gif.latex?E=mc^2" />
 
<img src="https://latex.codecogs.com/gif.latex?x%20%3D%20a_0%20&plus;%20%5Cfrac%7B1%7D%7Ba_1%20&plus;%20%5Cfrac%7B1%7D%7Ba_2%20&plus;%20%5Cfrac%7B1%7D%7Ba_3%20&plus;%20a_4%7D%7D%7D" />

Examples of claims might be :
- That the barometric pressure at location/time, i, is x, as measured by weather gauge, a
- That agent a will not default on a specified loan, i, as claimed (promised) by agent a
- That agent a has a probability of default x on a specified loan i, as measured by agent b
- That the bridge at location i is about to be washed away, as claimed by agent a 
- That the claim by agent a, regarding the bridge at location i, is consistent with other information held privately by agent b, and that agent b estimates it as likely to be valid with probability x
- That the answer for to question i

In a given domain a claim can be classed as consistent or inconsistent with other claims in that domain to some extent. (For example barometric measurements at close locations should be numerically similar.)

Furthermore if we assume that the validity and bias of claims made by a given agent are correlated we can use this to infer a latent variable for the bias and accuracy of all agents (given an observed set of claims) without being able to independently measure the underlying validity of the claims.  

<as demonstrated here>

Given this, if we have a stream of claims coming from all agents we can, in a principled way, estimate the validity of each new claim (given prior performance and consistency with existing claims).

Furthermore, we can measure the likelihood of each new claim. In a realtime scenario a suprising claim from a reliable source would have a low likelihood and should therefore be flagged as important. (Suprising claims from unreliable sources would have reasonable likelihood and are therefore not important).

<a href="https://creately.com/diagram/jo3gw9302/eyvMFJw8XXJiDfHzUILp2upUQg%3D"><img src="estimated_model.png" /></a>
