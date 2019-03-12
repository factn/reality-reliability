data {
  int<lower=1> N_RESPONSES;
  int<lower=1> N_STATEMENTS;
  int<lower=1> N_AGENTS;
  int<lower=1> STATEMENT[N_RESPONSES];
  int<lower=1> AGENT[N_RESPONSES];
}

parameters {
  vector<lower=0, upper=1>[N_STATEMENTS] truthiness;
  vector<lower=0>[N_AGENTS] agent_precision;
  vector<lower=0, upper=1>[N_RESPONSES] response;
}

transformed parameters {

  vector<lower=0, upper=1>[N_RESPONSES] mu1;
  vector<lower=0>[N_RESPONSES] phi1;
  
  for (r in 1:N_RESPONSES) {

    mu1[r]  = truthiness[STATEMENT[r]];
    phi1[r] = agent_precision[AGENT[r]];

  }    

}


model {
  
  truthiness ~ uniform(0, 1);
    
  agent_precision ~ exponential(0.01);

  response ~ beta(mu1  .* phi1, (1.0 - mu1)  .* phi1);

}
