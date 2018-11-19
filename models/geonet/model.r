library(rstan)
library(Matrix)
library(brms)
options(mc.cores = parallel::detectCores())

load('data/data.rdata')

W <- 1*as.matrix(sparseMatrix(i=c(W_sparse[, 1], W_sparse[, 2]), j=c(W_sparse[, 2], W_sparse[, 1])))
row.names(W) <- seq(nrow(W))
claims$value <- claims$value/10.0

# Fit the model
model <- brm(value ~ (1| agent), family='Beta', data=claims, autocor = cor_car(W, formula = ~ 1 | index))

saveRDS(model, file='model.rds')

















