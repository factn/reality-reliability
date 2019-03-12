#' ---
#' title: "`r basename(getwd())`"
#' author: YR
#' date: "`r Sys.Date()`"
#' output:
#'   rmdformats::readthedown:
#'     mathjax: null
#'     use_bookdown: false
#'     lightbox: true
#'     css: www/custom.css
#'     includes:
#'       in_header: "www/favicon.html"
#'     gallery: true
#'     toc_depth: 3
#'     toc_float:
#'       collapsed: false
#'       smooth_scoll: true
#' mode: selfcontained
#' ---

#+ setup, echo=FALSE, results="hide", message=FALSE
suppressPackageStartupMessages({
    library(data.table)
    library(ggplot2)
    library(knitr)
    library(kableExtra)
    library(formattable)
    library(gridExtra)
})
opts_chunk$set(echo=FALSE, cache.path='cache/cache_', fig.height=3, fig.width=4, cache=F)

library(data.table)

source('../functions.r')
load('generated/data.rdata')
load('generated/model-results.rdata')

col_fill <- "#43A1C9"
col_bord <- "#3898c2"

plot_dist <- function(draw.fun, title=draw.fun, ...) {
    d <- data.table(value = draw[[draw.fun]](...))
    if (d[, length(unique(value)) > 50]) {
        g <- ggplot(d, aes(x = value)) +
            scale_x_continuous() +
            scale_y_continuous(expand = c(0,0)) +
            labs(x = draw.fun, y = NULL, title = title) +
            geom_density(aes(y=..scaled..), fill = col_fill, colour = col_bord, alpha = 0.8)
    } else {
        dd <- d[, .N, value]
        dd[, p := N / sum(N)]
        g <- ggplot(dd, aes(x = value, y = p)) +
            geom_col(fill = col_fill, colour = col_bord, alpha = 0.8) +
            scale_y_continuous(expand = c(0,0)) +
            labs(title = title)
    }
    return(g)
}

plot_fun <- function(draw.fun, from, to, title=draw.fun, ...) {
    d <- data.table(x = seq(from, to, length.out = 100))
    d[, y := draw[[draw.fun]](x)]
    g <- ggplot(d, aes(x = x, y = y)) +
        geom_line(colour = col_fill) +
        scale_x_continuous() +
        scale_y_continuous(expand = c(0,0)) +
        labs(title = title)
    return(g)
}

#' # Input data
#'
#'
#' No. agents = `r data$N_AGENTS`
#'
#' No. statements = `r data$N_STATEMENTS`
#' 
#' ## Distributions
#'

nsamples <- 1e5

#+ cache=T
plot_dist('truthiness', n=nsamples )
#+ cache=T
plot_dist('n_answering_agents', n=nsamples, replace=T )
#+ cache=T
plot_dist('n_answers_for_agent', n=nsamples, replace=T )
#+ cache=T
plot_dist('agents_precision', n=nsamples )
#+ cache=T
plot_dist('times', n=nsamples )
#+ cache=T
plot_fun('time_effect', 0, 1000)


#' ## Agents answers
#' 
#+ cache=T
samples <- rbindlist(lapply(c(0.01, 0.5, 1, 5, 10, 100), function(s) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        data.table(mu = m, sd = s, value = draw$agent_responses(m, s, nsamples))
    }))
}))

samples[, `:=`(mu_lab = sprintf('truthiness = %0.2f', mu),
               sd_lab = sprintf('prec = %0.3f', sd))]
samples[, `:=`(mu_lab = factor(mu_lab, levels = unique(mu_lab)),
               sd_lab = factor(sd_lab, levels = unique(sd_lab)))]

samples[, value_cat := categorise(value)]

#+ fig.height=8, fig.width=12

p1 <- ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = col_fill, colour = col_bord) +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.title.x = element_text(margin = unit(c(2, 2, 9, 2), 'mm'))) +
    labs(x = 'Answer', y = NULL, title = 'Agent answers - continuous')

p2 <- ggplot(samples, aes(x = value_cat)) +
    geom_bar(aes(y = ..count../max(..count..)), fill = col_fill, colour = col_bord) +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1)) +
    labs(x = 'Answer', y = NULL, title = 'Agent answers - categorised')

grid.arrange(p1, p2, ncol=2)



#' # Model
#'

#' ## Statement truthiness
#'

truthiness[, y := rank(truthiness, ties='random')]
truthiness[, lab := sprintf('%i resp - %i ag. - %0.1f resp./ag.', responses, agents, responses_per_agent)]
tlabs1 <- truthiness[y < max(y) / 2]
tlabs2 <- truthiness[y >= max(y) / 2]

#+ fig.height=8, fig.width=12
offset <- 0.01 * diff(truthiness[, range(c(lcl, ucl))])
ggplot(truthiness, aes(y = y)) +
    geom_errorbarh(aes(xmin = lcl, xmax = ucl), colour = 'black') +
    geom_point(aes(x = mean), colour = 'black') +
    geom_point(aes(x = truthiness, colour = in_out_ci), alpha = 0.8) +
    geom_text(data = tlabs1, aes(x = ucl + offset, y = y, label = lab, colour = in_out_ci), hjust = 0, size = 2) +
    geom_text(data = tlabs2, aes(x = lcl - offset, y = y, label = lab, colour = in_out_ci), hjust = 1, size = 2) +
    scale_colour_manual(name = NULL,
                        values = c('in' = 'darkgreen', 'out' = 'red'),
                        labels = c('in' = 'truthiness within 95% c.i.',
                                   'out' = 'truthiness outside 95% c.i.')) +
    labs(x = 'Truthiness', y = 'Statement',
         title = sprintf('%i (%0.1f%%) statements with observed truthiness outside 95%% c.i.',
                         truthiness[, sum(in_out_ci == 'out')],
                         truthiness[, round(100 * mean(in_out_ci == 'out'), 1)])) +
    theme_minimal() +
    theme(legend.position = c(0.8, 0.2))


#' ## Agent precision
#'

agent_precision[, y := rank(prec, ties='random')]
agent_precision[, lab := sprintf('%i resp - %i st. - %0.1f resp./st.', responses, statements, responses_per_statement)]
tlabs1 <- agent_precision[y < max(y) / 2]
tlabs2 <- agent_precision[y >= max(y) / 2]

#+ fig.height=3, fig.width=12
offset <- 0.01 * diff(agent_precision[, range(c(lcl, ucl))])
ggplot(agent_precision, aes(y = y)) +
    geom_errorbarh(aes(xmin = lcl, xmax = ucl), colour = 'black') +
    geom_point(aes(x = mean), colour = 'black') +
    geom_point(aes(x = prec, colour = in_out_ci), alpha = 0.8) +
    geom_text(data = tlabs1, aes(x = ucl + offset, y = y, label = lab, colour = in_out_ci), hjust = 0, size = 3) +
    geom_text(data = tlabs2, aes(x = lcl - offset, y = y, label = lab, colour = in_out_ci), hjust = 1, size = 3) +
    scale_colour_manual(name = NULL,
                        values = c('in' = 'darkgreen', 'out' = 'red'),
                        labels = c('in' = 'precision within 95% c.i.',
                                   'out' = 'precision outside 95% c.i.')) +
    labs(x = 'Precision', y = 'Agent',
         title = sprintf('%i (%0.1f%%) agents with observed precision outside 95%% c.i.',
                         agent_precision[, sum(in_out_ci == 'out')],
                         agent_precision[, round(100 * mean(in_out_ci == 'out'), 1)])) +
    theme_minimal() +
    theme(legend.position = c(0.8, 0.2))


#' ## Trace plots
#'

#+ fig.height=90, fig.width=12, cache=F
ggplot(mcmc, aes(x = ch_sample, y = value, group = ch, colour = factor(ch))) +
    geom_line(alpha = 0.7) +
    scale_colour_discrete(guide = F) +
    scale_x_continuous(expand = c(0,0)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_wrap(~ variable, ncol = 2, scales = 'free', strip.position = 'left') +
    theme_minimal() +
    theme(strip.text.y=element_text(angle = 180),
          strip.placement="outside")
