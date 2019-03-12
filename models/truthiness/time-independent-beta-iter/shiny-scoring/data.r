library(data.table)
library(rstan)

load('../generated/data.rdata', v=T)
simdata0 <- copy(simdata)
simdata0[, iter_n := seq_len(.N)]
simdata0[, iter := sprintf('%0.4i', iter_n)]
simdata0[, st_ans_no := rowid(statement)]
simdata0[, st_ans_ag_no := rowid(statement, agent)]

models <- data.table(file=dir('../generated', 'model.*\\.rdata', full.names = T))
models[, iter := sub('.*model_([0-9]+)\\.rdata', '\\1', file)]
models[, iter_n := as.integer(iter)]
setorder(models, iter_n)
         

## * Last model (best estimate of everything)

lastmod <- tail(models, 1)[, file]
load(lastmod)

samples <- extract(model, c('truthiness', 'agent_precision'), permuted = F)
mcmc_final <- rbindlist(lapply(seq_len(dim(model)[2]), function(ch) {
    mcch <- as.data.table(samples[, ch, ])
    m <- melt(mcch, measure.vars = names(mcch))
    m[, ch_sample := rowid(variable)]
    m[, ch := ch]
    return(m)
}))
setorder(mcmc_final, variable, ch, ch_sample)
mcmc_final[, sample := rowid(variable)]
mcmc_final[, c('vartype', 'idx') := variable]
levels(mcmc_final$vartype) <- sub('\\[.*\\]', '', levels(mcmc_final$vartype))
levels(mcmc_final$idx) <- as.integer(sub('.*\\[([0-9]+)\\]', '\\1', levels(mcmc_final$idx)))
mcmc_final[, idx := as.integer(idx)]

truth <- mcmc_final[vartype == 'truthiness']
statements <- unique(simdata[, .(statement, statement_n)])
truth[statements, statement := i.statement, on = c('idx' = 'statement_n')]

prec <- mcmc_final[vartype == 'agent_precision']
agents <- unique(simdata[, .(agent, agent_n)])
prec[agents, agent := i.agent, on = c('idx' = 'agent_n')]

truth_final <- truth
prec_final <- prec



## * Prior model

priormod <- head(models, 1)[, file]
load(priormod)

samples <- extract(model, c('truthiness', 'agent_precision'), permuted = F)
mcmc_final <- rbindlist(lapply(seq_len(dim(model)[2]), function(ch) {
    mcch <- as.data.table(samples[, ch, ])
    m <- melt(mcch, measure.vars = names(mcch))
    m[, ch_sample := rowid(variable)]
    m[, ch := ch]
    return(m)
}))
setorder(mcmc_final, variable, ch, ch_sample)
mcmc_final[, sample := rowid(variable)]

truth_prior <- mcmc_final[variable == 'truthiness']
prec_prior <- mcmc_final[variable == 'agent_precision']


## * "Real" values

real_truth <- data.table(st_or_ag = seq_len(data$N_STATEMENTS), value=data$statements_truthiness)
real_prec  <- data.table(st_or_ag = seq_len(data$N_AGENTS),     value=data$agents_precision)



save(simdata0, models, truth_final, prec_final, truth_prior, prec_prior,
     real_truth, real_prec, file = 'data/data.rdata')
