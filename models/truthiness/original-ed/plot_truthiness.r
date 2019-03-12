library(ggplot2)
library(ggthemes)
library(scales)
library(data.table)
library(rstan)

colour <- economist_pal()(6)[1]
alpha <- 1 

model <- readRDS('model.rds')
data <- readRDS('data.rds')
ex <- extract(model)

ilogit <- function(x){exp(x)/(1+exp(x))}

pp_truthiness <- data.table(x=data$truthiness, y=apply(ex$truthiness, 2, mean), ymin=apply(ex$truthiness, 2, quantile, 0.025), ymax=apply(ex$truthiness, 2, quantile, 0.975))
g <- ggplot(pp_truthiness, aes(x=ilogit(x), y=y, ymin=ymin, ymax=ymax)) + 
    geom_point(colour=colour, fill=colour, alpha=alpha) + 
    geom_errorbar(colour=colour, alpha=alpha) + 
    xlab('Claim truthiness') + 
    ylab('Estimated claim truthiness') +
    theme_economist_white(gray_bg = FALSE) +
    scale_colour_economist() +
    coord_cartesian(ylim=c(0, 1), xlim=c(-0.02, 1.02), expand=FALSE)


ggsave(g, width=6, height=4, file='generated/truthiness.png', dpi = 600)

