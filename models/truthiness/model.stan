data {
    int N_AGENTS;
    int N_RESPONSES;
    int N_STATEMENTS;
    real RESPONSE[N_RESPONSES];
    int<lower=1, upper=N_AGENTS> AGENT[N_RESPONSES];
    int<lower=1, upper=N_STATEMENTS> STATEMENT[N_RESPONSES];
}

parameters {
    real<lower=1E-6> phi;
    real bias_agent[N_AGENTS];
    real<lower=1E-6> sd_agent[N_AGENTS];
    real error_agent[N_RESPONSES];
    real mu_truthiness;
    real<lower=1E-6> sd_truthiness;
    real truthiness[N_STATEMENTS];
}

transformed parameters {
    real alpha[N_RESPONSES];
    real beta[N_RESPONSES];
    real mu[N_RESPONSES];

    for (r in 1 : N_RESPONSES){
        mu[r] = inv_logit(truthiness[STATEMENT[r]] + error_agent[r]);
        alpha[r] = mu[r] * phi;
        beta[r] = (1 - mu[r]) * phi;
    }

}

model {
    phi ~ normal(0, 1);
    
    mu_truthiness ~ normal(0, 1);
    sd_truthiness ~ normal(0, 1);

    for (s in 1:N_STATEMENTS){
        truthiness[s] ~ normal(mu_truthiness, sd_truthiness);
    }
    
    for (a in 1:N_AGENTS){
        bias_agent[a] ~ normal(0, 1);
        sd_agent[a] ~ normal(0, 1);
    }
    
    error_agent ~ normal(bias_agent[AGENT], sd_agent[AGENT]);
    RESPONSE ~ beta(alpha, beta);
}

generated quantities {
    real pp_response[N_RESPONSES]; 
    real ll_response[N_RESPONSES]; 

    for (r in 1: N_RESPONSES){
        pp_response[r] = beta_rng(alpha[r], beta[r]);
        ll_response[r] = beta_lpdf(RESPONSE[r] | alpha[r], beta[r]);
    }
}

