functions {
  /**
  * Return the log probability of a proper conditional autoregressive (CAR) prior 
  * with a sparse representation for the adjacency matrix
  * From the STAN CAR case study: 
  * http://mc-stan.org/documentation/case-studies/mbjoseph-CARStan.html
  *
  * @param phi Vector containing the parameters with a CAR prior
  * @param tau Precision parameter for the CAR prior (real)
  * @param alpha Dependence (usually spatial) parameter for the CAR prior (real)
  * @param W_sparse Sparse representation of adjacency matrix (int array)
  * @param n Length of phi (int)
  * @param W_n Number of adjacent pairs (int)
  * @param D_sparse Number of neighbors for each location (vector)
  * @param lambda Eigenvalues of D^{-1/2}*W*D^{-1/2} (vector)
  *
  * @return Log probability density of CAR prior up to additive constant
  */
  real sparse_car_lpdf(vector phi, real tau, real alpha, 
    int[,] W_sparse, vector D_sparse, vector lambda, int n, int W_n) {
      row_vector[n] phit_D; // phi' * D
      row_vector[n] phit_W; // phi' * W
      vector[n] ldet_terms;
    
      phit_D = (phi .* D_sparse)';
      phit_W = rep_row_vector(0, n);
      for (i in 1:W_n) {
        phit_W[W_sparse[i, 1]] = phit_W[W_sparse[i, 1]] + phi[W_sparse[i, 2]];
        phit_W[W_sparse[i, 2]] = phit_W[W_sparse[i, 2]] + phi[W_sparse[i, 1]];
      }
    
      for (i in 1:n) ldet_terms[i] = log1m(alpha * lambda[i]);
      return 0.5 * (n * log(tau)
                    + sum(ldet_terms)
                    - tau * (phit_D * phi - alpha * (phit_W * phi)));
  }
}


data {
    int N_AGENTS;
    int N_CLAIMS;
    int N_POINTS;
    real OBSERVATION[N_CLAIMS];
    int<lower=1, upper=N_AGENTS> AGENT[N_CLAIMS];
    int<lower=1, upper=N_POINTS> POINT[N_CLAIMS];
    int<lower=1> COUNT[N_CLAIMS];

    int W_N;
    int W_SPARSE[W_N, 2]; 
    vector[N_POINTS] D_SPARSE;
    vector[N_POINTS] LAMBDA;
}

parameters {
    real<lower=1E-5> phi;
    real<lower=1E-5> sd_agent;
    real agent[N_AGENTS];
    real alpha_car;
    real mu_point;
    real sigma_area;
    real<lower=1E-5> sd_point;
    vector[N_POINTS] point;
}

transformed parameters {
    real alpha[N_CLAIMS];
    real beta[N_CLAIMS];
    real mu[N_CLAIMS];
    real tau_area;
    for (c in 1 : N_CLAIMS){
        mu[c] = inv_logit(agent[AGENT[c]] + point[POINT[c]]);
        alpha[c] = mu[c] * phi;
        beta[c] = (1 - mu[c]) * phi;
    }
    tau_area = pow(sigma_area, -2); 
}

model {
    phi ~ normal(0, 1);
    sd_agent ~ normal(0, 1);
  
    sigma_area ~ normal(0, 1);
    alpha_car ~ beta(1, 1);
    point ~ sparse_car(tau_area, alpha_car, W_SPARSE, D_SPARSE, LAMBDA, N_POINTS, W_N);  
    agent ~ student_t(1, 0, sd_agent);
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

