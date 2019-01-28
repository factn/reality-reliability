library(rstan)
options(mc.cores = parallel::detectCores())
data <- readRDS(data, file='data.rds')


# Fit the model
model <- stan('model.stan', 
    model_name = "facts",
    data = data,
    chains = 4, 
    iter = 2000
)
saveRDS(model, file='model.rds')















