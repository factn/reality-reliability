suppressPackageStartupMessages({
    library(rstan)
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())
})

load('generated/data.rdata', v=F)
simdata0 <- copy(simdata)

source('../functions.r')

models <- dir('generated', 'model_[0-9].*\\.rdata', full.names = T)

## * All models but final
i=1
pids <- progressbar(length(models), 100)
allresults <- rbindlist(lapply(seq_along(models), function(i) {

    if (i %in% pids) cat('*')
    mod <- models[i]
    iter <- sub('.*generated/model_([0-9]{4})\\.rdata', '\\1', mod)
    load(mod, v=F)
    samples <- extract(model, c('truthiness', 'agent_precision', 'll_next_response'), permuted = F)

    if (!is.null(nrow(samples))) {

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
        suppressWarnings({levels(mcmc$idx) <- as.integer(sub('.*\\[([0-9]+)\\]', '\\1', levels(mcmc$idx)))})

        mcmc[, idx := as.integer(idx)]

        statements <- unique(simdata[, .(statement, statement_n)])
        agents     <- unique(simdata[, .(agent, agent_n)])

        truth <- mcmc[vartype == 'truthiness']
        truth[statements, st_or_ag := i.statement, on = c('idx' = 'statement_n')]

        prec <- mcmc[vartype == 'agent_precision']
        prec[agents, st_or_ag := i.agent, on = c('idx' = 'agent_n')]
        
        ll <- mcmc[vartype == 'll_next_response']
        ll[, ll_iter := sprintf('%0.4i', as.integer(iter) + 1)]
        
        both <- rbind(truth[, .(vartype, st_or_ag, sample, ch, ch_sample, value)],
                      prec[, .(vartype, st_or_ag, sample, ch, ch_sample, value)],
                      ll[, .(vartype, ll_iter, sample, ch, ch_sample, value)], fill=T)
        both[, iter := iter]

        return(both)

    } else return(NULL)
}))


## * Final model

mod <- 'generated/model_final.rdata'
load(mod)

iter <- 'final'
samples <- extract(model, c('truthiness', 'agent_precision', 'll_response'), permuted = F)

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
suppressWarnings({levels(mcmc$idx) <- as.integer(sub('.*\\[([0-9]+)\\]', '\\1', levels(mcmc$idx)))})

mcmc[, idx := as.integer(idx)]

statements <- unique(simdata[, .(statement, statement_n)])
agents     <- unique(simdata[, .(agent, agent_n)])

truth <- mcmc[vartype == 'truthiness']
truth[statements, st_or_ag := i.statement, on = c('idx' = 'statement_n')]

prec <- mcmc[vartype == 'agent_precision']
prec[agents, st_or_ag := i.agent, on = c('idx' = 'agent_n')]
        
ll <- mcmc[vartype == 'll_response']
ll[, ll_iter := sprintf('%0.4i', idx)]

both <- rbind(truth[, .(vartype, st_or_ag, sample, ch, ch_sample, value)],
              prec[, .(vartype, st_or_ag, sample, ch, ch_sample, value)],
              ll[, .(vartype, ll_iter, sample, ch, ch_sample, value)], fill=T)
both[, iter := iter]


allresults <- rbind(allresults, both, fill=T)



saveRDS(allresults, 'generated/truthiness-precision-all-models.rds')

