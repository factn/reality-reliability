library(data.table)
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())
load('generated/data.rdata', v=T)

options(warn = 1)

data$AGENT       <- simdata$agent
data$STATEMENT   <- simdata$statement
data$RESPONSE    <- simdata$answer
data$N_RESPONSES <- length(data$RESPONSE)

nchains <- 1
## inits <- lapply(seq_len(nchains), function(x) {
##     list(truthiness      = runif(data$N_STATEMENTS, 0.1, 0.9),
##          agent_precision = rep(10, data$N_AGENTS),
##          RESPONSE        = runif(data$N_RESPONSES, 0.1, 0.9),
##          response        = runif(data$N_RESPONSES, 0.1, 0.9))
## })
              
# Fit the model
model <- stan('sim.stan', 
              model_name = "sim",
              ## init       = inits,
              data       = data,
              diagnostic_file = 'diag.txt',
              chains     = nchains, 
              iter       = 200
              )

codasamples <- As.mcmc.list(model)
mcmc <- rbindlist(lapply(1:length(codasamples), function(ch) {
    d <- data.table(codasamples[[ch]])
    d[, chain := ch]
    d[, ch_sample := 1:.N]
    return(melt(d, id.vars = c('chain', 'ch_sample')))
}))

r <- rbindlist(lapply(model@sim$samples, function(x) return(x)))
m <- melt(r, measure.vars = names(r))
m[, sample := rowid(variable)]

m[, vartype := sub('\\[.*\\]', '', variable)]
m[grep('.*\\[([0-9]+)\\]', variable), idx := as.integer(sub('.*\\[([0-9]+)\\]', '\\1', variable))]

m[, max(idx), vartype]

vs <- unique(m$variable)

plottrace <- function(v) {png('test.png'); m[variable == v, plot(sample, value, type='l')]; title(v); dev.off()}


ind1 <- rep(NA_integer_, length.out = length(unvars))
singleidx <- grepl('.*\\[([0-9]+)\\].*', unvars)

mcmc <- rbindlist(lapply(1:length(codasamples), function(ch) {
    d <- data.table(codasamples[[ch]])
    d[, chain := ch]
    d[, ch_sample := 1:.N]
    return(melt(d, id.vars = c('chain', 'ch_sample')))
}))


response <- rbeta(data$N_RESPONSES, alpha, beta)


saveRDS(model, file='generated/model.rds', compress=F)
