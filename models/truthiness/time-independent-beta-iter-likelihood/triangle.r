library(data.table)

vals <- expand.grid(innovation = seq(0, 1, 0.01),
                    foresight  = seq(0, 1, 0.01),
                    shift      = seq(0, 1, 0.01))
setDT(vals)


check <- function(I, F, S) {
    ifelse(((I + F) >= S) & ((F + S) >= I) & ((S + I) >= F), 1, 0)
}
vals[, good := check(innovation, foresight, shift)]

vals[, mean(good)]

library(rgl)


vals[good == 1]

vals

I=0.4; F=0.7; S=0.2
score <- function(I, F, S) {
    if (!(I < (F + S) | F < (I + S) | S < (I + F))) {
        
a_IS <- acos((I^2 + S^2 - F^2) / (2*I*S))

IS <- c(0,0)
FS <- c(S,0)

IF <- IS[1] + I * Re(exp(1i * a_IS


    altx <- t[i, x] + t[i, dist2next] * Re(exp((0+1i) * phis))
        alty <- t[i, y] + t[i, dist2next] * Im(exp((0+1i) * phis))
