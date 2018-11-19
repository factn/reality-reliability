library(rstan)
options(mc.cores = parallel::detectCores())

load('data/data.rdata')


data <- list(OBSERVATION=value,
    AGENT=AGENT,
    POINT=index,
    QUAKE=quake,
    COUNT=count,
    D_SPARSE=D_sparse,
    W_N = W_n,
    W_SPARSE = W_sparse,
    LAMBDA = lambda,
    N_CLAIMS = nrow(claims),
    N_AGENTS = max(claims$agent),
    N_QUAKES = max(claims$quake),
    N_POINTS = max(claims$index))

# Fit the model
model <- stan('model.stan', 
    model_name = "simple_test",
    data = data,
    chains = 4, 
    iter = 2000
)

saveRDS(model, file='model.rds')

















