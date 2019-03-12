data {
  int<lower=1> N_RESPONSES;
  int<lower=1> N_STATEMENTS;
  int<lower=1> N_AGENTS;
  int<lower=1,upper=N_STATEMENTS> STATEMENT[N_RESPONSES];
  int<lower=1,upper=N_AGENTS> AGENT[N_RESPONSES];
  real<lower=0, upper=1> RESPONSE[N_RESPONSES];
}

parameters {
  /* real logit_mu_truthiness; */
  /* real<lower=0> logit_sd_truthiness; */
  /* vector[N_STATEMENTS] logit_truthiness; */
  vector<lower=0.0001, upper=0.9999>[N_STATEMENTS] truthiness;

  vector<lower=0>[N_AGENTS] agent_precision;
  /* vector<lower=0, upper=1>[N_RESPONSES] response; */
}

transformed parameters {

  /* vector<lower=0, upper=1>[N_RESPONSES] mu1; */
  /* vector<lower=0>[N_RESPONSES] phi1; */
/*   vector[N_RESPONSES] alpha; */
/*   vector[N_RESPONSES] beta; */
  /* vector<lower=0, upper=1>[N_STATEMENTS] truthiness; */

  vector<lower=0, upper=1>[N_RESPONSES] mu1;
  vector<lower=0>[N_RESPONSES] phi1;

  vector<lower=0>[N_RESPONSES] alpha;
  vector<lower=0>[N_RESPONSES] beta;

  /* vector[N_RESPONSES] alpha1; */
  /* vector[N_RESPONSES] beta1; */

  /* truthiness = inv_logit(logit_truthiness); */

  for (r in 1:N_RESPONSES) {
    mu1[r]	= truthiness[STATEMENT[r]];
    phi1[r]	= agent_precision[AGENT[r]];
  }
  
  alpha	= mu1 .* phi1;
  beta	= (1.0 - mu1) .* phi1;

}


model {
  
  truthiness ~ uniform(0, 1);
    
  /* logit_mu_truthiness ~ normal(0, 1); */
  /* logit_sd_truthiness ~ uniform(0, 2); */
  /* logit_truthiness ~ normal(logit_mu_truthiness, logit_sd_truthiness); */

  agent_precision ~ exponential(0.1);
  
  RESPONSE ~ beta(alpha, beta);

}


  /* for (r in 1:N_RESPONSES) { */

  /*   response[r] ~ beta(alpha[r], beta[r]); */

  /*   /\* print("alpha[r]=", alpha[r], "; beta[r]=", beta[r], "; response[r]=", response[r], "; RESPONSE[r]=", RESPONSE[r]);  *\/ */
    
  /* } */

/* } */

/* generated quantities { */
/*   vector[N_STATEMENTS] truthiness; */
/* /\*   real pp_response[N_RESPONSES];  *\/ */
/* /\*   real ll_response[N_RESPONSES];  *\/ */
  
/* /\*   for (r in 1: N_RESPONSES){ *\/ */
/* /\*     pp_response[r] = beta_rng(alpha[r], beta[r]); *\/ */
/* /\*     ll_response[r] = beta_lpdf(RESPONSE[r] | alpha[r], beta[r]); *\/ */
/* /\*   } *\/ */
/* } */

