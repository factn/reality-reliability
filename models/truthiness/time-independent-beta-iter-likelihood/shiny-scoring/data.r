library(data.table)
library(rstan)

allresults <- readRDS('../generated/truthiness-precision-all-models.rds')
load('../generated/all-scores.rdata', v=T)

load('../generated/data.rdata', v=T)
simdata0 <- copy(simdata)

models <- data.table(file=dir('../generated', 'model.*\\.rdata', full.names = T))
models[!grep('final', file), iter := sub('.*model_([0-9]+)\\.rdata', '\\1', file)]
models[!grep('final', file), iter_n := as.integer(iter)]

models[grep('final', file), iter_n := max(models$iter_n, na.rm=T) + 1]
models[grep('final', file), iter := 'final']
setorder(models, iter_n, na.last=T)
         

## * Last model (best estimate of everything)

mcmc_final <- allresults[iter == 'final']

truth <- mcmc_final[vartype == 'truthiness']
truth[, statement := st_or_ag]

prec <- mcmc_final[vartype == 'agent_precision']
prec[, agent := st_or_ag]

truth_final <- truth
prec_final <- prec


## * Prior model

mcmc_prior  <- allresults[iter == '0000']
truth_prior <- mcmc_prior[vartype == 'truthiness']
prec_prior  <- mcmc_prior[vartype == 'agent_precision']


## * Trim off unnecessary data
allresults <- allresults[!(vartype %in% c('ll_next_response', 'll_response'))]
allresults <- allresults[iter %in% c('0000', likelihoods$ll_iter, 'final')]

## * "Real" values

real_truth <- data.table(st_or_ag = seq_len(data$N_STATEMENTS), value=data$statements_truthiness)
real_prec  <- data.table(st_or_ag = seq_len(data$N_AGENTS),     value=data$agents_precision)


save(allresults, simdata0, models, truth_final, prec_final, truth_prior, prec_prior, likelihoods,
     real_truth, real_prec, scores, likelihoods,
     file = 'data/data.rdata', compress=F)
