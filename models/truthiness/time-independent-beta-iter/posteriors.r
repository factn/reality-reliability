suppressPackageStartupMessages({
    library(rstan)
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())
})

load('generated/data.rdata', v=F)
simdata0 <- copy(simdata)

source('../functions.r')

models <- dir('generated', 'model.*\\.rdata', full.names = T)

i=1
pids <- progressbar(length(models), 100)
allresults <- rbindlist(lapply(seq_along(models), function(i) {

    if (i %in% pids) cat('*')
    mod <- models[i]
    iter <- sub('.*generated/model_([0-9]{4})\\.rdata', '\\1', mod)
    load(mod, v=F)
    samples <- extract(model, c('truthiness', 'agent_precision'), permuted = F)
    mcmc <- rbindlist(lapply(seq_len(dim(model)[2]), function(ch) {
        mcch <- as.data.table(samples[, ch, ])
        m <- melt(mcch, measure.vars = names(mcch))
        m[, ch_sample := rowid(variable)]
        m[, ch := ch]
        return(m)
    }))
    setorder(mcmc, variable, ch, ch_sample)
    mcmc[, sample := rowid(variable)]

    mcmc[, c('vartype', 'idx') := variable]
    levels(mcmc$vartype) <- sub('\\[.*\\]', '', levels(mcmc$vartype))
    levels(mcmc$idx) <- as.integer(sub('.*\\[([0-9]+)\\]', '\\1', levels(mcmc$idx)))
    mcmc[, idx := as.integer(idx)]

    statements <- unique(simdata[, .(statement, statement_n)])
    agents     <- unique(simdata[, .(agent, agent_n)])

    truth <- mcmc[vartype == 'truthiness']
    truth[statements, st_or_ag := i.statement, on = c('idx' = 'statement_n')]

    prec <- mcmc[vartype == 'agent_precision']
    prec[agents, st_or_ag := i.agent, on = c('idx' = 'agent_n')]
    
    both <- rbind(truth[, .(vartype, st_or_ag, sample, ch, ch_sample, value)],
                  prec[, .(vartype, st_or_ag, sample, ch, ch_sample, value)])
    both[, iter := iter]
    return(both)

}))


saveRDS(allresults, 'generated/truthiness-precision-all-models.rds')
