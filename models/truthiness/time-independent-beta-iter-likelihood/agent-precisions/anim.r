library(data.table)
library(ggplot2)
library(gganimate)
library(transport)
library(colorspace)
library(gridExtra)

allresults <- readRDS('../generated/truthiness-precision-all-models.rds')
setkey(allresults, iter, st_or_ag)

dir.create('frames', showWarnings=F)

max_st <- 15

load('../generated/data.rdata', v=T)

simdata[, iter := sprintf('%0.4i', 1:.N)]

statements <- seq_len(max_st) # sort(as.numeric(na.omit(allresults[vartype == 'truthiness', unique(st_or_ag)])))
agents <- seq_len(data$N_AGENTS) #sort(as.numeric(na.omit(allresults[vartype == 'agent_precision', unique(st_or_ag)])))
n_statements <- length(statements)
n_agents <- length(agents)

priors <- allresults[iter == '0000']
prior_truth <- priors[vartype == 'truthiness']
prior_prec  <- priors[vartype == 'agent_precision']

## * Restrict number of statements answered
r <- allresults[, max(st_or_ag), iter]
w <- r[max(which(V1 %in% max_st)), iter]
allresults <- allresults[iter <= w]

iters <- setdiff(sort(unique(allresults$iter)), '0000')

t_real <- data.table(st_or_ag = seq_len(data$N_STATEMENTS), value = data$statements_truthiness)
t_real <- t_real[st_or_ag <= max_st]

p_real <- data.table(st_or_ag = seq_len(data$N_AGENTS),     value = data$agents_precision)


pids <- progressbar(length(iters), 100)
i=361
for (i in seq_along(iters)) {
    frame <- iters[i]

    outfile <- sprintf('frames/frame_%s.png', frame)
    if (!file.exists(outfile)) {
        png(outfile, width = 1200, height = 800)

        df <- allresults[iter == frame]

        truth <- df[vartype == 'truthiness']
        prec  <- df[vartype == 'agent_precision']

        ## truth[, real_value := data$statements_truthiness[st_or_ag]]
        ## prec[ , real_value := data$agents_precision[st_or_ag]]
        
        answer <- simdata[iter == frame]
        answer_t <- answer[, .(st_or_ag = statement, value = answer)]
        answer_p <- answer[, .(st_or_ag = agent, value = 0)]
        
        ## * Truthiness
        missing_st <- setdiff(statements, unique(truth$st_or_ag))
        if (length(missing_st)) {
            truth <- rbind(truth,
                           rbindlist(lapply(missing_st, function(st) {
                               p <- copy(prior_truth)
                               p[, st_or_ag := st]
                               return(p)
                           })))
        }

        ## * Agent precision
        missing_pr <- setdiff(agents, unique(prec$st_or_ag))
        if (length(missing_pr)) {
            prec <- rbind(prec,
                          rbindlist(lapply(missing_pr, function(ag) {
                              p <- copy(prior_prec)
                              p[, st_or_ag := ag]
                              return(p)
                          })))
        }

        truth_wdist <- rbindlist(lapply(statements, function(st) {
            data.table(st = st, wdist = wasserstein1d(truth[st_or_ag == st, value], prior_truth[, value]))
        }))
        prec_wdist <- rbindlist(lapply(agents, function(ag) {
            data.table(ag = ag, wdist = wasserstein1d(prec[st_or_ag == ag, value], prior_prec[, value]))
        }))

        truth[truth_wdist, wdist := i.wdist, on = c('st_or_ag' = 'st')]
        prec[prec_wdist, wdist := i.wdist, on = c('st_or_ag' = 'ag')]
        
        gt <- ggplot(truth, aes(x = value)) +
            geom_density(aes(y = ..scaled.., fill = wdist), color = 'grey50', show.legend=F) +
            geom_vline(data = t_real, aes(xintercept = value), colour = 'blue') +
            facet_wrap(~ st_or_ag, nrow = 6) +
            scale_fill_continuous_sequential('Heat2', trans = 'sqrt', limits = c(0, 1)) +
            theme_minimal() +
            scale_x_continuous(limits = c(0, 1), breaks = c(0, .5, 1)) +
            geom_vline(data = answer_t, aes(xintercept = value), color = 'red') +
            labs(x = 'Truthiness', y = '', title = paste0('Model ', frame))

        gp <- ggplot(prec, aes(x = value)) +
            geom_density(aes(y = ..scaled.., fill = wdist), color = 'grey50', show.legend=F) +
            geom_vline(data = p_real, aes(xintercept = value), colour = 'blue') +
            facet_wrap(~ st_or_ag, ncol = 2) +
            scale_fill_continuous_sequential('BluGrn', trans = 'sqrt') +
            theme_minimal() +
            geom_vline(data = answer_p, aes(xintercept = value), color = 'red') +
            scale_x_continuous(limits = c(0, NA)) +
            labs(x = 'Agent precision', y = '', title = '')

        print(cowplot::plot_grid(gt, gp, rel_widths = c(2, 1)))

        dev.off()
    }   
}
