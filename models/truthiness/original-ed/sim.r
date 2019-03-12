library(data.table)
source('../functions.r')

n1 <- 1
n2 <- 1e5
(mu_truthiness <- rnorm(n1, 0, 1))
(sd_truthiness <- rnorm(n1, 0, 1))
## (z_truthiness  <- rnorm(n1, 0, 1))


mu= ilogit(mu_truthiness + sd_truthiness);

(agent_precision <- pmax(0, rnorm(n1, 0, 1)))
alpha = mu * agent_precision;
beta = (1 - mu) * agent_precision;

resp <- rbeta(n, alpha, beta)

mean(resp)
mu

hist(resp)
