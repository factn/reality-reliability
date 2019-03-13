estBetaParams <- function(mu=NULL, var=NULL, alpha=NULL, beta=NULL) {
    ## ** mu & var -> alpha & beta
    if (!is.null(mu) & !is.null(var)) {
        ## from http://stats.stackexchange.com/questions/12232/calculating-the-parameters-of-a-beta-distribution-using-the-mean-and-variance
        alpha <- round(((1 - mu)/var - 1/mu) * mu^2, 8)
        beta <- round(alpha * (1/mu - 1), 8)
        return(list(alpha = alpha, beta = beta))
    } else if (!is.null(alpha) & !is.null(beta)) {
    ## ** alpha & beta -> mu & var
        mu <- alpha / (alpha + beta)
        var <- (alpha * beta) / ((alpha * beta)^2 * (alpha + beta + 1))
        return(list(mu = mu, var = var))
    } else stop('Either `alpha` and `beta` or `mu` and `var` should be NULL')
}

sample_logit <- function(pmean, pse, n=1000) {
    se_beta <- pse/(pmean*(1-pmean)) ## calculate se(beta(S)) from se(S), uses delta method
    logit_p <- rnorm(n=n, mean=log(pmean/(1-pmean)), sd=se_beta) ## apply normal variation to logit(s)
    p <- 1 / (1 + exp(-logit_p)) ## back-transform
    return(p)
}

logit  <- function(x) log(x / (1-x))
ilogit <- function(x) 1 / (1 + exp(-x))

categorise <- function(x, brks=seq(0, 1, length.out=6),
                       labels=c('false', 'mostly false', 'partially true', 'mostly true', 'true')) {
    stopifnot(length(labels) == length(brks) - 1)
    cut(x, breaks = brks, labels, include.lowest=T)
}

cat_as_num <- function(cat, brks=seq(0, 1, length.out=6)) {
    if (!is.factor(cat)) stop('`cat` should be a factor')
    cc <- as.integer(cat)
    midpoints <- ((data.table::shift(brks,1) + brks) / 2)[-1]
    return(midpoints[cc])
}



progressbar <-  function (n, length = 50) {
    if (length > n) 
        length = n
    cat(sprintf("|%s|\n", paste(rep("-", length - 2), collapse = "")))
    s <- 1:n
    sp <- s/n * length
    target <- 1:length
    ids <- sapply(target, function(x) which.min(abs(sp - x)))
    return(ids)
}
