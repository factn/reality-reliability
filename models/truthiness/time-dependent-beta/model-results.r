library(data.table)
library(rstan)

load('generated/data.rdata', v=T)

model <- readRDS('generated/model.rds')

## summary(model)
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

t <- mcmc[vartype == 'truthiness']
t[, truthiness := data$statements_truthiness[idx]]
t <- t[, .(mean = mean(value),
      lcl = quantile(value, 0.025, names = F),
      ucl = quantile(value, 0.975, names = F)),
  .(statement=idx, truthiness)]
t[, in_out_ci := ifelse(truthiness < lcl | truthiness > ucl, 'out', 'in')]
t <- merge(t, simdata[, .(responses = .N, agents = length(unique(agent)), responses_per_agent = .SD[, .N, agent][, mean(N)]),
                      statement], by = 'statement', all.x=T)

p <- mcmc[vartype == 'agent_precision']
p[, prec := data$agents_precision[idx]]
p <- p[, .(mean = mean(value),
           lcl = quantile(value, 0.025, names = F),
           ucl = quantile(value, 0.975, names = F)),
       .(agent=idx, prec)]
p[, in_out_ci := ifelse(prec < lcl | prec > ucl, 'out', 'in')]
p <- merge(p, simdata[, .(responses = .N, statements = length(unique(statement)),
                          responses_per_statement = .SD[, .N, statement][, mean(N)]),
                      agent], by = 'agent', all.x=T)

truthiness <- t
agent_precision <- p

save(mcmc, truthiness, agent_precision,
     file='generated/model-results.rdata', compress=F)
