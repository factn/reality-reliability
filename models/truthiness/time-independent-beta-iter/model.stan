data {
  int<lower=1> N_RESPONSES;
  int<lower=1> N_STATEMENTS;
  int<lower=1> N_AGENTS;
  int<lower=1> STATEMENT[N_RESPONSES];
  int<lower=1> AGENT[N_RESPONSES];
  real<lower=0, upper=1> RESPONSE[N_RESPONSES];
}


parameters {
  vector<lower=0.000001, upper=0.999999>[N_STATEMENTS] truthiness;
  vector<lower=0>[N_AGENTS] agent_precision;
}


transformed parameters {
  vector<lower=0, upper=1>[N_RESPONSES] mu1;
  vector<lower=0>[N_RESPONSES] phi1;
  vector<lower=0>[N_RESPONSES] alpha;
  vector<lower=0>[N_RESPONSES] beta;

  for (r in 1:N_RESPONSES) {
    mu1[r]	= truthiness[STATEMENT[r]];
    phi1[r]	= agent_precision[AGENT[r]];
  }
  
  alpha	= mu1 .* phi1;
  beta	= (1.0 - mu1) .* phi1;
}


model {
  truthiness ~ uniform(0, 1);
  agent_precision ~ uniform(0.1, 100);
  RESPONSE ~ beta(alpha, beta);
}



generated quantities {
  /* real ll_response[N_RESPONSES]; */
  real<lower=0, upper=1> response[N_RESPONSES];

  /* for (r in 1: N_RESPONSES){ */
  /*   ll_response[r] = beta_lpdf(RESPONSE[r] | alpha[r], beta[r]); */
  /* } */

  for (r in 1: N_RESPONSES) {
    response[r] = beta_rng(alpha[r], beta[r]);
  }
}


/* generated quantities { */
/*   real ll_response[N_RESPONSES]; */
/*   for (r in 1: N_RESPONSES){ */
/*     ll_response[r] = beta_lpdf(RESPONSE[r] | alpha[r], beta[r]); */
/*   } */
/* } */

