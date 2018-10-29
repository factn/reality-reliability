data {
    int N_AGENTS;
    int N_CLAIMS;
    int N_POINTS;
    real OBSERVATION[N_CLAIMS];
    int<lower=1, upper=N_AGENTS> AGENT[N_CLAIMS];
    int<lower=1, upper=N_POINTS> POINT[N_CLAIMS];
}

parameters {
    real<lower=1E-5> phi;
    real<lower=1E-5> sd_agent;
    real agent[N_AGENTS];
    real mu_point;
    real<lower=1E-5> sd_point;
    real point[N_POINTS];
}

transformed parameters {
    real alpha[N_CLAIMS];
    real beta[N_CLAIMS];
    real mu[N_CLAIMS];

    for (c in 1 : N_CLAIMS){
        mu[c] = inv_logit(agent[AGENT[c]] + point[POINT[c]]);
        alpha[c] = mu[c] * phi;
        beta[c] = (1 - mu[c]) * phi;
    }

}

model {
    phi ~ normal(0, 1);
    sd_agent ~ normal(0, 1);
    mu_point ~ normal(0, 1);
    sd_point ~ normal(0, 1);

    agent ~ student_t(1, 0, sd_agent);
    point ~ normal(mu_point, sd_point);
    OBSERVATION ~ beta(alpha, beta);
}

generated quantities {
    real pp_observation[N_CLAIMS]; 
    real ll_observation[N_CLAIMS]; 

    for (c in 1: N_CLAIMS){
        pp_observation[c] = beta_rng(alpha[c], beta[c]);
        ll_observation[c] = beta_lpdf(OBSERVATION[c] | alpha[c], beta[c]);
    }
}

