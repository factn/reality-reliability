library(rstan)
options(mc.cores = parallel::detectCores())


# Make some sample data
data = list(N_POINTS=10,
    N_AGENTS = 10,
    N_CLAIMS = 200)

data$AGENT = with(data, sample(1:N_AGENTS, N_CLAIMS, replace=TRUE))
data$POINT = with(data, sample(1:N_POINTS, N_CLAIMS, replace=TRUE))

phi = 10

agent = with(data, 2*(seq(0, N_AGENTS - 1)/(N_AGENTS - 1) - 0.5))
point = with(data, 4*((seq(N_POINTS) - 0.5 - N_POINTS/2)/N_POINTS))

ilogit =function(x){exp(x)/(1+exp(x))}

mu = with(data, ilogit(agent[AGENT] + point[POINT]))
alpha = mu * phi
beta = (1 - mu) * phi
data$OBSERVATION = with(data, rbeta(N_CLAIMS, alpha, beta))


# Fit the model
model <- stan('model.stan', 
    model_name = "simple_test",
    data = data,
    chains = 4, 
    iter = 2000
)

# Save the results
data$mu = mu
data$agent = agent
data$point = point
saveRDS(model, file='model.rds')
saveRDS(data, file='data.rds')

















