data {
    int N_AGENTS;
    int N_RESPONSES;
    int N_STATEMENTS;
    real RESPONSE[N_RESPONSES];
    int<lower=1, upper=N_AGENTS> AGENT[N_RESPONSES];
    int<lower=1, upper=N_STATEMENTS> STATEMENT[N_RESPONSES];
}

parameters {
    real<lower=1E-5> phi;
    real<lower=1E-5> bias_agent[N_AGENTS];
    real<lower=1E-5> sd_agent[N_AGENTS];
    real<lower=1E-6, upper=0.99999> cosmic_agent[N_AGENTS];
    real error_agent[N_RESPONSES];
    real mu_truthiness;
    real<lower=1E-5> sd_truthiness;
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
        cosmic_agent[a] ~ uniform(0, 1);
    }

    /* Allow for  a mixture distribution, with some predictions being totally wrong */
    for (r in 1:N_RESPONSES){
        error_agent[r] ~ normal(bias_agent[AGENT[r]], sd_agent[AGENT[r]]);
        target += log_mix(cosmic_agent[AGENT[r]],
            beta_lpdf(RESPONSE[r] | alpha[r], beta[r]),
            uniform_lpdf(RESPONSE[r] | 0, 1));
    }
}

/*
generated quantities {
    real pp_response[N_RESPONSES]; 
    real ll_response[N_RESPONSES]; 

    for (c in 1: N_RESPONSES){
        pp_response[c] = beta_rng(alpha[c], beta[c]);
        ll_response[c] = beta_lpdf(RESPONSE[c] | alpha[c], beta[c]);
    }
}
*/

