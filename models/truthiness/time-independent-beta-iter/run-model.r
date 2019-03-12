suppressPackageStartupMessages({
    library(rstan)
    rstan_options(auto_write = TRUE)
    options(mc.cores = parallel::detectCores())
    library(RPushbullet)
})

key <- "o.2XMTZ9q2TWvHEb9fdhHU1ps39CNxFaEE"
devices <- c("ujxarO332aWsjz7O3P0Jl6", "ujxarO332aWsjAiVsKnSTs")

load('generated/data.rdata', v=F)

options(warn = 1)

iter <- as.numeric(commandArgs(trailingOnly=T))
if (length(iter) == 0)  iter <- 1

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

save(simdata, model, file=sprintf('generated/model_%0.4i.rdata', iter), compress=F)
