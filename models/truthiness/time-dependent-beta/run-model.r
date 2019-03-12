library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
load('generated/data.rdata', v=T)

options(warn = 1)

data$AGENT       <- simdata$agent
data$STATEMENT   <- simdata$statement
data$RESPONSE    <- pmin(0.999999, pmax(0.000001, simdata$answer))
data$N_RESPONSES <- length(data$RESPONSE)

nchains <- 4

nwarmup  <- 1000
nsamples <- 1000

## Fit the model
model <- stan('model.stan', 
              model_name = "facts",
              data       = data,
              chains     = nchains, 
              iter       = nwarmup + nsamples,
              warmup     = nwarmup
              )

saveRDS(model, file='generated/model.rds', compress=F)
