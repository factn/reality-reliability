#' ---
#' title: "Playing with distributions"
#' author: YR
#' date: "`r Sys.Date()`"
#' output:
#'   rmdformats::readthedown:
#'     mathjax: null
#'     use_bookdown: false
#'     lightbox: true
#'     css: custom.css
#'     includes:
#'       in_header: "favicon.html"
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
})
opts_chunk$set(echo=FALSE, cache.path='cache/cache_', cache=T)

library(data.table)

source('../functions.r')

figW <- 8
figH <- 6


categorise <- function(x, brks=seq(0, 1, length.out=6),
                       labels=c('false', 'mostly false', 'partially true', 'mostly true', 'true')) {
    stopifnot(length(labels) == length(brks) - 1)
    cut(x, breaks = brks, labels, include.lowest=T)
}

#' # Inverse-logit

n <- 1e5

#' ## Mean on natural scale, sd on logit scale

#+ fig.height=figH, fig.width=figW

samples <- rbindlist(lapply(c(0.01, 0.2, 1, 2), function(s) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        data.table(mu = m, sd_logit = s, value = ilogit(rnorm(n, logit(m), s)))
    }))
}))

samples[, `:=`(mu_lab = sprintf('mu = %0.2f', mu),
               sdl_lab = sprintf('sdl = %0.2f', sd_logit))]

#' ### Continuous
#' 
ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = 'grey70', colour = 'grey50') +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(sdl_lab ~ mu_lab, scales = 'free_y')

#' ### Categorised
#' 
samples[, value_cat := categorise(value)]

ggplot(samples, aes(x = value_cat)) +
    geom_bar(fill = 'grey70', colour = 'grey50') +
    facet_grid(sdl_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1))





#' ## Mean and s.d. on natural scale
#'
#' Uses delta method and not very accurate close to 0 or 1

#+ fig.height=figH, fig.width=figW

samples <- rbindlist(lapply(c(0.01, 0.2, 0.5, 1), function(s) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        data.table(mu = m, sd = s, value = sample_logit(m, s, n))
    }))
}))

samples[, `:=`(mu_lab = sprintf('mu = %0.2f', mu),
               sd_lab = sprintf('sd = %0.2f', sd))]

#' ### Continuous
#' 
ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = 'grey70', colour = 'grey50') +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y')

#' ### Categorised
#' 
samples[, value_cat := categorise(value)]

ggplot(samples, aes(x = value_cat)) +
    geom_bar(fill = 'grey70', colour = 'grey50') +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1))


#' ## Mean and CV on natural scale
#'
#' Uses delta method and not very accurate close to 0 or 1

#+ fig.height=figH, fig.width=figW

samples <- rbindlist(lapply(c(0.01, 0.2, 0.5, 1, 2), function(cv) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        s <- m * cv
        data.table(mu = m, cv = cv, sd = s, value = sample_logit(m, s, n))
    }))
}))

samples[, `:=`(mu_lab = sprintf('mu = %0.2f', mu),
               cv_lab = sprintf('cv = %0.2f', cv))]

#' ### Continuous
#' 
ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = 'grey70', colour = 'grey50') +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(cv_lab ~ mu_lab, scales = 'free_y')

#' ### Categorised
#' 
samples[, value_cat := categorise(value)]

#+ fig.height=7, fig.width=figW
ggplot(samples, aes(x = value_cat)) +
    geom_bar(fill = 'grey70', colour = 'grey50') +
    facet_grid(cv_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1))



## * Beta

#' # Beta distribution
#'
#' ## Alpha and beta from mean + sd
#' 
#' Variance depending on mean and bounded by `mean * (1 - mean)`

#+ fig.height=figH, fig.width=figW

samples <- rbindlist(lapply(c(0.01, 0.1, 0.2, 0.5), function(s) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        bp <- estBetaParams(mu = m, var = pmin(m * (1 - m), s^2))
        data.table(mu = m, sd_logit = s, value = rbeta(n, bp$alpha, bp$beta))
    }))
}))

samples[, `:=`(mu_lab = sprintf('mu = %0.2f', mu),
               sd_lab = sprintf('sd = %0.2f', sd_logit))]

#' ### Continuous
#' 
ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = 'grey70', colour = 'grey50') +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y')

#' ### Categorised
#' 
samples[, value_cat := categorise(value)]

ggplot(samples, aes(x = value_cat)) +
    geom_bar(fill = 'grey70', colour = 'grey50') +
    facet_grid(sd_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1))


#' ## Mu + phi parametrisation
#' 
#+ fig.height=figH, fig.width=figW

samples <- rbindlist(lapply(c(0.01, 0.5, 1, 5, 10, 100), function(phi) {
    rbindlist(lapply(c(0.01, 0.1, 0.25, 0.5), function(m) {
        alpha <- m * phi
        beta  <- (1 - m) * phi
        data.table(mu = m, phi = phi, value = rbeta(n, alpha, beta))
    }))
}))

samples[, `:=`(mu_lab = sprintf('mu = %0.2f', mu),
               phi_lab = sprintf('phi = %3.2f', phi))]
samples[, `:=`(mu_lab = factor(mu_lab, levels = unique(mu_lab)),
               phi_lab = factor(phi_lab, levels = unique(phi_lab)))]

#' ### Continuous
#'
#' 
ggplot(samples, aes(x = value)) +
    geom_density(aes(y=..scaled..), fill = 'grey70', colour = 'grey50') +
    scale_x_continuous(limits = c(0, 1)) +
    scale_y_continuous(expand = c(0,0)) +
    facet_grid(phi_lab ~ mu_lab, scales = 'free_y')

#' ### Categorised
#' 
samples[, value_cat := categorise(value)]

#+ fig.height=7, fig.width=figW
ggplot(samples, aes(x = value_cat)) +
    geom_bar(fill = 'grey70', colour = 'grey50') +
    facet_grid(phi_lab ~ mu_lab, scales = 'free_y') +
    theme(axis.text.x = element_text(angle = 45, hjust=1))

