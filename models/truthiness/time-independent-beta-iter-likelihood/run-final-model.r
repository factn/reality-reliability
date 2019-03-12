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

options(warn = 1)

cat('--- Running final model ---\n')

tryCatch({

    simdata[, agent_f := factor(agent, levels = sort(unique(agent)))]
    simdata[, agent_n := as.integer(agent_f)]
    simdata[, statement_f := factor(statement, levels = sort(unique(statement)))]
    simdata[, statement_n := as.integer(statement_f)]

    data$AGENT <- as.array(simdata$agent_n)
    data$N_AGENTS <- max(simdata$agent_n)

    data$STATEMENT   <- as.array(simdata$statement_n)
    data$N_STATEMENTS <- max(simdata$statement_n)

    data$RESPONSE    <- as.array(pmin(0.999999, pmax(0.000001, simdata$answer)))
    data$N_RESPONSES <- length(data$RESPONSE)

    nchains <- 6

    nwarmup  <- 500
    nsamples <- 400

    ## * Fit the model
    model <- stan('model-final.stan', 
                  model_name = "factsfin",
                  data       = data,
                  pars       = c('truthiness', 'agent_precision', 'll_response'),
                  chains     = nchains, 
                  iter       = nwarmup + nsamples,
                  warmup     = nwarmup
                  )
            
}, error = function(e) {
    pbPost("note", title="Error running final model", body=as.character(e) , verbose=T, debug=T, apikey=key)
}
)

save(simdata, model, file='generated/model_final.rdata', compress=F)
