suppressPackageStartupMessages({
    library(data.table)
    library(rstan)
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())
    library(RPushbullet)
})

key <- "o.2XMTZ9q2TWvHEb9fdhHU1ps39CNxFaEE"
devices <- c("ujxarO332aWsjz7O3P0Jl6", "ujxarO332aWsjAiVsKnSTs")

load('generated/data.rdata', v=F)
simdata0 <- copy(simdata)

options(warn = 1)

maxiter <- as.integer(commandArgs(trailingOnly=T))
if (length(maxiter) == 0)  maxiter <- 0L

## simdata0[max(which(statement == 15)), iter]

cat('--- Running model', maxiter, '---\n')

tryCatch({

    simdata <- simdata0[seq_len(maxiter+1L)]
    simdata[, agent_f := factor(agent, levels = sort(unique(agent)))]
    simdata[, agent_n := as.integer(agent_f)]
    simdata[, statement_f := factor(statement, levels = sort(unique(statement)))]
    simdata[, statement_n := as.integer(statement_f)]

    fitdata <- simdata[seq_len(maxiter)]
    
    data$AGENT <- as.array(fitdata$agent_n)
    data$N_AGENTS <- max(simdata$agent_n)

    data$STATEMENT   <- as.array(fitdata$statement_n)
    data$N_STATEMENTS <- max(simdata$statement_n)

    data$RESPONSE    <- as.array(pmin(0.999999, pmax(0.000001, fitdata$answer)))
    data$N_RESPONSES <- length(data$RESPONSE)

    ## * Last record = next answer
    nextans <- tail(simdata,1)
    data$NEXT_STATEMENT <- nextans$statement_n
    data$NEXT_AGENT     <- nextans$agent_n
    data$NEXT_RESPONSE  <- nextans$answer
    
    nchains <- 6

    nwarmup  <- 500
    nsamples <- 400

    ## * Fit the model
    if (maxiter > 0) {
        model <- stan('model.stan', 
                      model_name = "facts",
                      data       = data,
                      pars       = c('truthiness', 'agent_precision', 'll_next_response'),
                      chains     = nchains, 
                      iter       = nwarmup + nsamples,
                      warmup     = nwarmup
                      )
    } else {
        model <- stan('model0.stan', 
                      model_name = "facts0",
                      data       = data,
                      pars       = c('truthiness', 'agent_precision', 'll_next_response'),
                      chains     = nchains, 
                      iter       = nwarmup + nsamples,
                      warmup     = nwarmup
                      )
    }
    
}, error = function(e) {
    pbPost("note", title=sprintf("Error running model %i", maxiter), body=as.character(e) , verbose=T, debug=T, apikey=key)
}
)

save(simdata, model, file=sprintf('generated/model_%0.4i.rdata', maxiter), compress=F)
