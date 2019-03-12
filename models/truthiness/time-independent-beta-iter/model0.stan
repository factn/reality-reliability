data {

}

parameters {
  real<lower=0.000001, upper=0.999999> truthiness;
  real<lower=0> agent_precision;
}

transformed parameters {
  real<lower=0, upper=1> mu1;
  real<lower=0> phi1;
  real<lower=0> alpha;
  real<lower=0> beta;

  mu1	= truthiness;
  phi1	= agent_precision;
  
  alpha	= mu1 .* phi1;
  beta	= (1.0 - mu1) .* phi1;
}

model {
  truthiness ~ uniform(0, 1);
  agent_precision ~ uniform(0.1, 100);
}

generated quantities {
  real<lower=0, upper=1> response;
  response = beta_rng(alpha, beta);
}

