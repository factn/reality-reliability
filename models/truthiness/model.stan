data {
    int N_AGENTS;
    int N_RESPONSES;
    int N_STATEMENTS;
    real RESPONSE[N_RESPONSES];
    int<lower=1, upper=N_AGENTS> AGENT[N_RESPONSES];
    int<lower=1, upper=N_STATEMENTS> STATEMENT[N_RESPONSES];
}

parameters {
    real<lower=1E-6> phi[N_AGENTS];
    real mu_truthiness;
    real<lower=1E-6> sd_truthiness;
    real z_truthiness[N_STATEMENTS];
}

transformed parameters {
    real alpha[N_RESPONSES];
    real beta[N_RESPONSES];
    real mu[N_RESPONSES];

    for (r in 1 : N_RESPONSES){
        mu[r] = inv_logit(mu_truthiness + z_truthiness[STATEMENT[r]] * sd_truthiness);
        alpha[r] = mu[r] * phi[AGENT[r]];
        beta[r] = (1 - mu[r]) * phi[AGENT[r]];
    }

}

model {
    
    mu_truthiness ~ normal(0, 1);
    sd_truthiness ~ normal(0, 1);

    for (s in 1:N_STATEMENTS){
    	z_truthiness[s] ~ normal(0, 1);
    }
    
    for (a in 1:N_AGENTS){
    	phi[a] ~ normal(0, 1);
    }
    
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

