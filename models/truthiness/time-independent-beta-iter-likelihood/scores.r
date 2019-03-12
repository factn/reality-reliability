library(data.table)
library(transport)

allresults <- readRDS('generated/truthiness-precision-all-models.rds')
allresults <- allresults[vartype == 'truthiness']

## suppressPackageStartupMessages({
##     library(rstan)
##     rstan_options(auto_write = TRUE)
##     options(mc.cores = parallel::detectCores())
##     library(RPushbullet)
##     library(transport)
## })

## key <- "o.2XMTZ9q2TWvHEb9fdhHU1ps39CNxFaEE"
## devices <- c("ujxarO332aWsjz7O3P0Jl6", "ujxarO332aWsjAiVsKnSTs")

source('../functions.r')

options(warn = 1)

setkey(allresults, iter, st_or_ag)

## * Last model (best estimate of everything)

lastmod <- allresults[iter == max(iter)]

load(sprintf('generated/model_%s.rdata', lastmod[1, iter]))
simdata[, iter := sprintf('%0.4i', seq_len(.N))]
simdata[, iter_n := seq_len(.N)]
simdata[, iter := sprintf('%0.4i', iter_n)]
simdata[, st_ans_no := rowid(statement)]
simdata[, st_ans_ag_no := rowid(statement, agent)]


## * Prior model

priormod <- allresults[iter == '0000']
t_prior <- priormod[, value]

scores <- list()

iters <- unique(allresults$iter)
iters <- setdiff(iters, '0000')
pids <- progressbar(length(iters), 100)
prev <- priormod

i=100
## for (i in 1:10) {
for (i in seq_along(iters)) {
    if (i %in% pids) cat('*')

    it <- iters[i]
    ans <- simdata[iter == it]

    ## * Posteriors
    
    ## ** Previous posterior
    if (ans$st_ans_no != 1) {
        p_truth <- prev[st_or_ag == ans$statement, value]
    } else p_truth <- t_prior
    
    ## ** Current posterior
    curr <- allresults[iter == iters[i]]
    c_truth <- curr[st_or_ag == ans$statement, value]

    ## ** Final
    f_truth <- lastmod[st_or_ag == ans$statement, value]


    ## * the 3 sides of the triangle

    innovation <- wasserstein1d(p_truth, ans$answer)
    foresight  <- wasserstein1d(f_truth, ans$answer)
    shift      <- wasserstein1d(p_truth, f_truth)

    if (((innovation + foresight) >= shift) & ((foresight + shift) >= innovation) & ((shift + innovation) >= foresight)) {
        score <- (innovation^2 + shift^2 - foresight^2) / (2 * shift)
    } else score <- NA_real_

    scores[[i]] <- cbind(ans, data.table(innovation, foresight, shift, score))

    prev <- curr
}

scores <- rbindlist(scores)


saveRDS(scores, 'generated/all-scores.rds')

