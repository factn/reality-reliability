library(data.table)
library(transport)

allresults <- readRDS('generated/truthiness-precision-all-models.rds')
truthiness  <- allresults[vartype == 'truthiness']
likelihoods <- allresults[vartype %in% c('ll_next_response', 'll_response')]
rm(allresults); gc()

source('../functions.r')
load('generated/data.rdata')

options(warn = 1)

setkey(truthiness, iter, st_or_ag)
setkey(likelihoods, ll_iter)

## * Last model (best estimate of everything)

lasttruth <- truthiness[iter == max(iter)]
load(sprintf('generated/model_%s.rdata', lasttruth[1, iter])) # to get full simdata

iters <- unique(truthiness$iter)

## * Assign prior to first statement to get previous value
truthiness[iter == '0000', st_or_ag := 1]


## * Previous value
prev_truthiness <- copy(truthiness)
prev_truthiness[, next_iter := iters[match(iter, iters)+1]]

truthiness[prev_truthiness[!is.na(next_iter)],
           value_prev := i.value,
           on = c('iter' = 'next_iter', 'st_or_ag', "sample", "ch", "ch_sample")]

## * Final value
truthiness[lasttruth, value_last := i.value, on = c('st_or_ag', 'sample', 'ch', 'ch_sample')]


## * Calculate scores
pids <- progressbar(length(iters), 100)

by='0103'; grp=2; dt=truthiness[iter == by]
process <- function(dt, by, grp) {
    if (grp %in% pids) cat('*')

    ans <- simdata[iter == by]
    st <- ans[, statement]

    st_dat <- dt[st_or_ag == st]
    
    ## ans <- simdata[iter == by]
    p_truth <- st_dat[, value_prev]
    c_truth <- st_dat[, value]
    f_truth <- st_dat[, value_last]
    
    innovation <- wasserstein1d(p_truth, ans$answer)
    miss  <- wasserstein1d(f_truth, ans$answer)
    shift      <- wasserstein1d(p_truth, f_truth)

    if (((innovation + miss) >= shift) & ((miss + shift) >= innovation) & ((shift + innovation) >= miss)) {
        score <- (innovation^2 + shift^2 - miss^2) / (2 * shift)
    } else score <- NA_real_

    data.table(innovation, miss, shift, score)
}

scores <- truthiness[!(iter %in% c('0000','final')), process(.SD, .BY, .GRP), iter]


## * Get likelihoods

ll_new <- likelihoods[vartype == 'll_next_response', .(ll_iter, sample, ch, ch_sample, ll_new=value)]
ll_end <- likelihoods[vartype == 'll_response',      .(ll_iter, sample, ch, ch_sample, ll_end=value)]

likelihoods <- merge(ll_new, ll_end,
                     by.x = c('ll_iter', 'sample', 'ch', 'ch_sample'),
                     by.y = c('ll_iter', 'sample', 'ch', 'ch_sample'),
                     all=F)

likelihoods[, ll_diff := ll_end - ll_new]


save(scores, likelihoods, file='generated/all-scores.rdata')

