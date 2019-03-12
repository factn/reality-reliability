library(data.table)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
data <- readRDS(data, file='generated/data.rds')

data$RESPONSE <- pmin(0.999, pmax(0.001, data$RESPONSE))
data$N_RESPONSES <- length(data$RESPONSE)


# Fit the model
model <- stan('model.stan', 
    model_name = "facts",
    data = data,
    chains = 4, 
    iter = 2000
)
saveRDS(model, file='generated/model.rds')


dt <- with(data, data.table(agent=AGENT, statement=STATEMENT, response=RESPONSE))
dt[, .(n_responses = .N, n_agents = length(unique(agent))), statement]
