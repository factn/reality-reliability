data {
  int N_AGENTS;
  int N_RESPONSES;
  int N_STATEMENTS;
  real RESPONSE[N_RESPONSES];
  int<lower=1, upper=N_AGENTS> AGENT[N_RESPONSES];
  int<lower=1, upper=N_STATEMENTS> STATEMENT[N_RESPONSES];
}

parameters {
  vector<lower=1E-6>[N_AGENTS] agent_precision;
  real<lower=0,upper=1> mu_truthiness;
  real<lower=1E-6> sd_truthiness;
  real z_truthiness[N_STATEMENTS];
}

transformed parameters {
  real alpha[N_RESPONSES];
  real beta[N_RESPONSES];
  vector<lower=0,upper=1>[N_RESPONSES] mu;

  for (r in 1 : N_RESPONSES) {
    mu[r] = inv_logit(mu_truthiness + z_truthiness[STATEMENT[r]] * sd_truthiness);
    alpha[r] = mu[r] * agent_precision[AGENT[r]];
    beta[r] = (1 - mu[r]) * agent_precision[AGENT[r]];
  }

}

model {
    
  mu_truthiness ~ normal(0, 1);
  sd_truthiness ~ normal(0, 1);

  for (s in 1:N_STATEMENTS){
    z_truthiness[s] ~ normal(0, 1);
  }
    
  for (a in 1:N_AGENTS){
    agent_precision[a] ~ exponential(0.001);
  }
    
  RESPONSE ~ beta(alpha, beta);
}

generated quantities {
  real pp_response[N_RESPONSES]; 
  real ll_response[N_RESPONSES]; 
  real truthiness[N_STATEMENTS];

  for (r in 1: N_RESPONSES){
    pp_response[r] = beta_rng(alpha[r], beta[r]);
    ll_response[r] = beta_lpdf(RESPONSE[r] | alpha[r], beta[r]);
  }

  for (s in 1: N_STATEMENTS){
    truthiness[s] = inv_logit(mu_truthiness + z_truthiness[s] * sd_truthiness);
  }
}

