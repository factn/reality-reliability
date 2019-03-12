data {
  int<lower=1> N_RESPONSES;
  int<lower=1> N_STATEMENTS;
  int<lower=1> N_AGENTS;
  int<lower=1> STATEMENT[N_RESPONSES];
  int<lower=1> AGENT[N_RESPONSES];
  vector<lower=0, upper=1>[N_RESPONSES] RESPONSE;
}

parameters {
  vector[N_STATEMENTS] logit_mu_truthiness;
  real<lower=0.001> logit_sd_truthiness;

  vector[N_STATEMENTS] logit_truthiness;
  
  vector<lower=1e-6>[N_AGENTS] agent_precision;
  /* vector<lower=0, upper=1>[N_RESPONSES] response; */
}

/* transformed parameters { */

/*   /\* vector<lower=0, upper=1>[N_RESPONSES] mu1; *\/ */
/*   /\* vector<lower=0>[N_RESPONSES] phi1; *\/ */
/* /\*   vector[N_RESPONSES] alpha; *\/ */
/* /\*   vector[N_RESPONSES] beta; *\/ */

/* } */


model {

  vector[N_STATEMENTS] truthiness;

  vector[N_RESPONSES] mu1;
  vector[N_RESPONSES] phi1;

  vector[N_RESPONSES] alpha;
  vector[N_RESPONSES] beta;

  /* vector[N_RESPONSES] alpha1; */
  /* vector[N_RESPONSES] beta1; */

  truthiness = inv_logit(logit_truthiness);

  for (r in 1:N_RESPONSES) {
    mu1[r]	= truthiness[STATEMENT[r]];
    phi1[r]	= agent_precision[AGENT[r]];
  }    

  alpha	= mu1 .* phi1;
  beta	= (1.0 - mu1) .* phi1;
  
  /* truthiness ~ uniform(0, 1); */
    
  /* agent_precision ~ uniform(0.0001, 10); */
  /* /\* agent_precision ~ exponential(0.0001); *\/ */

  logit_mu_truthiness ~ normal(0, 1);
  logit_sd_truthiness ~ uniform(0, 2);

  logit_truthiness ~ normal(logit_mu_truthiness, logit_sd_truthiness);

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

