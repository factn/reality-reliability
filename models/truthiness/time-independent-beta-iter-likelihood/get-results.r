suppressPackageStartupMessages({
    library(rstan)
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())
    library(RPushbullet)
    library(transport)
})

key <- "o.2XMTZ9q2TWvHEb9fdhHU1ps39CNxFaEE"
devices <- c("ujxarO332aWsjz7O3P0Jl6", "ujxarO332aWsjAiVsKnSTs")

load('generated/data.rdata', v=F)

source('../functions.r')

options(warn = 1)


## * Last model (best estimate of everything)

lastmod <- tail(sort(dir('generated', 'model.*\\.rdata', full.names = T)), 1)
load(lastmod)

samples <- extract(model, c('truthiness'), permuted = F)
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
statements <- unique(simdata[, .(statement, statement_n)])
mcmc_final[statements, statement := i.statement, on = c('idx' = 'statement_n')]


## * Prior model

priormod <- head(sort(dir('generated', 'model.*\\.rdata', full.names = T)), 1)
load(priormod)

samples <- extract(model, c('truthiness'), permuted = F)
mcmc_prior <- rbindlist(lapply(seq_len(dim(model)[2]), function(ch) {
    mcch <- as.data.table(samples[, ch, ])
    m <- melt(mcch, measure.vars = names(mcch))
    m[, ch_sample := rowid(variable)]
    m[, ch := ch]
    return(m)
}))

setorder(mcmc_prior, variable, ch, ch_sample)
mcmc_prior[, sample := rowid(variable)]

mcmc_prior[, c('variable', 'vartype') := 'truthiness']

statements <- unique(simdata[, .(statement, statement_n)])
mcmc_prior[statements, statement := i.statement, on = c('idx' = 'statement_n')]





## * Read all results

mods <- sort(dir('generated', 'model.*\\.rdata', full.names = T))
mods <- data.table(iter = as.numeric(sub('generated/model_([0-9]{4})\\.rdata', '\\1', mods)))


get_res <- function(iter) {
    load(sprintf('generated/model_%0.4i.rdata', iter))
    
}

rbindlist(lapply(mods, 

iter <- as.numeric(commandArgs(trailingOnly=T))
if (length(iter) == 0)  iter <- 1

simdata0 <- copy(simdata)
simdata0[, answer_no := 1L:.N]
simdata0[, statement_answer := rowid(statement)]

simdata0

curr_answer    <- simdata0[iter]
curr_statement <- curr_answer$statement
curr_agent     <- curr_answer$agent
curr_response  <- curr_answer$answer
curr_answer_no <- curr_answer$statement_answer

if (curr_answer_no > 1) {
    
} else {
    
}

st_rows <- simdata0[, which(statement == curr_statement)]


currmod <- sprintf('generated/model_%0.4i.rdata', iter)
prevmod <- 
lastmod <- tail(sort(dir('generated', 'model.*\\.rdata', full.names = T)), 1)


mod0 <- load(sprintf('generated/model_0000.rdata', iter))
mod <- load(sprintf('generated/model_%0.4i.rdata', iter))

## mods <- sort(dir('generated', 'model.*\\.rdata', full.names = T))

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


wasserstein1d(x1, x2)





## * Originality

## * Foresight

## * Shift



cat('--- Running model', iter, '---\n')

tryCatch({

    simdata <- simdata[seq_len(iter)]

    simdata[, agent_f := factor(agent, levels = sort(unique(agent)))]
    simdata[, agent_n := as.integer(agent_f)]

    simdata[, statement_f := factor(statement, levels = sort(unique(statement)))]
    simdata[, statement_n := as.integer(statement_f)]
    
    data$AGENT <- as.array(simdata$agent_n)
    data$N_AGENTS <- length(unique(data$AGENT))

    data$STATEMENT   <- as.array(simdata$statement_n)
    data$N_STATEMENTS <- length(unique(data$STATEMENT))

    data$RESPONSE    <- as.array(pmin(0.999999, pmax(0.000001, simdata$answer)))
    data$N_RESPONSES <- length(data$RESPONSE)

    nchains <- 6

    nwarmup  <- 500
    nsamples <- 400


    ## Fit the model
    if (iter != 0) {
        model <- stan('model.stan', 
                      model_name = "facts",
                      data       = data,
                      pars       = c('truthiness', 'agent_precision'),
                      chains     = nchains, 
                      iter       = nwarmup + nsamples,
                      warmup     = nwarmup
                      )
    } else {
        model <- stan('model0.stan',
                      model_name = "facts",
                      data       = data,
                      pars       = c('truthiness', 'agent_precision', 'response'),
                      chains     = nchains, 
                      iter       = nwarmup + nsamples,
                      warmup     = nwarmup
                      )
        
    }
    
}, error = function(e) {
    pbPost("note", title=sprintf("Error running model %i", iter), body=as.character(e) , verbose=T, debug=T, apikey=key)
}
)

save(simdata, model, file=sprintf('generated/result_%0.4i.rdata', iter), compress=F)

