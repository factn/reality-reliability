library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
load('generated/data.rdata', v=T)

options(warn = 2)

data$AGENT       <- simdata$agent
data$STATEMENT   <- simdata$statement
data$RESPONSE    <- simdata$answer
data$N_RESPONSES <- length(data$RESPONSE)

simdata[, truthiness := data$statements_truthiness[statement]]
simdata[, agent_prec := data$agents_precision[agent]]

nchains <- 1
## inits <- lapply(seq_len(nchains), function(x) {
##     list(truthiness      = runif(data$N_STATEMENTS, 0.1, 0.9),
##          agent_precision = rep(10, data$N_AGENTS),
##          RESPONSE        = runif(data$N_RESPONSES, 0.1, 0.9),
##          response        = runif(data$N_RESPONSES, 0.1, 0.9))
## })
              
# Fit the model
model <- stan('model.stan', 
              model_name = "facts",
              ## init       = inits,
              data       = data,
              chains     = nchains, 
              diagnostic_file = 'generated/diag.txt',
              iter       = 2000
              )

saveRDS(model, file='generated/model.rds', compress=F)
