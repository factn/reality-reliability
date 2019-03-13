get_mod_res <- function(mod) {

    ## mod = '../generated/model_0005.rdata'
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

}

check <- function(I, F, S) {
    ifelse(((I + F) >= S) & ((F + S) >= I) & ((S + I) >= F), T, F)
}

score <- function(I, F, S) {
    (I^2 + S^2 - F^2) / (2 * F)
}

ordinal_suffix <- function(x, html=T) {
    y <- as.character(x)
    z <- substr(y, nchar(y), nchar(y))
    s <- ifelse(z == '1' & x %% 100 != '11', 'st',
         ifelse(z == '2' & x %% 100 != '12', 'nd',
         ifelse(z == '3' & x %% 100 != '13', 'rd',
                'th')))
    if (html) {
        return(sprintf('%s<sup>%s</sup>', y, s))
    } else return(paste0(x, s))
}
