library(shiny)
library(shinyWidgets)
library(shinyjs)
library(data.table)
library(shinydashboard)
library(ggplot2)
library(gridExtra)
library(cowplot)
library(rstan)
library(transport)

load('../generated/data.rdata', v=F)

source('../../functions.r')
source('functions.r')

options(warn = 1)

load('data/data.rdata', v=F)

mytheme <- function() {
    theme(plot.background=element_rect(fill='#283639', colour = NA),
          panel.background=element_rect(fill='#283639', colour = NA),
          panel.grid.major=element_line(colour = '#313E41FF'),
          panel.grid.minor=element_line(colour = '#2C3A3DFF'),
          axis.text.x = element_text(colour = 'grey70'),
          axis.text.y = element_text(colour = 'grey70'),
          plot.title = element_text(colour = 'grey90'))
}

input <- list(iter       = 100)

## * SERVER
shinyServer(function(input, output, session) {

    output$iter <- renderUI(sliderInput("iter", label = "Answer", min = 1, max = max(models$iter_n),
                                        value = 5))

    observeEvent(input$nextbutt, {
        updateSliderInput(session, "iter", value = input$iter + 1)
    })
    observeEvent(input$prevbutt, {
        updateSliderInput(session, "iter", value = input$iter - 1)
    })

    observeEvent(input$nextbutts, {
        ans <- answer()
        w <- simdata0[, min(which(statement > ans$statement & st_ans_no == 1))]
        updateSliderInput(session, "iter", value = simdata0[w, iter_n])
    })
    observeEvent(input$prevbutts, {
        ans <- answer()
        w <- simdata0[, max(which(statement < ans$statement & st_ans_no == 1))]
        updateSliderInput(session, "iter", value = simdata0[w, iter_n])
    })

    observeEvent(input$nextbutta, {
        ans <- answer()
        w <- simdata0[, min(which(agent == ans$agent & iter_n > ans$iter_n))]
        updateSliderInput(session, "iter", value = simdata0[w, iter_n])
    })
    observeEvent(input$prevbutta, {
        ans <- answer()
        w <- simdata0[, max(which(agent == ans$agent & iter_n < ans$iter_n))]
        updateSliderInput(session, "iter", value = simdata0[w, iter_n])
    })
    
    answer <- reactive({
        req(input$iter)

        ans <- simdata0[iter_n == input$iter]

        return(ans)
    })

    output$answer_txt <- renderText({
        req(answer())
        ans <- answer()
        return(ans[1, sprintf('Agent %i responded that statement %i was %0.1f%% true at time %0.2f<br>Response #%i for this statement, but #%i for this agent and statement',
                      agent, statement, 100 * answer, time, st_ans_no, st_ans_ag_no)])
    })
    
    prev_res <- reactive({
        req(input$iter)
        if (input$iter > 0) {
            previter <- models[which(iter_n == input$iter)-1, iter]
            prev <- allresults[iter == previter]
            return(prev)
        } else {
            prev <- NULL
            return(prev)
        }
    })

    sel_res <- reactive({
        req(input$iter)
        curriter <- models[iter_n == input$iter, iter]
        sel <- allresults[iter == curriter]
        return(sel)
    })

    output$somelog <- renderPrint({
        print(answer())
    })

    ## * Quantities of interest + score
    three_versions <- reactive({

        ans <- answer()
        req(ans)
        st  <- ans$statement
        ag  <- ans$agent
        
        prev <- prev_res()
        sel <- sel_res()
        
        p_truth <- prev[vartype == 'truthiness'      & st_or_ag == st]
        p_prec  <- prev[vartype == 'agent_precision' & st_or_ag == ag]
        if (!nrow(p_truth)) p_truth <- truth_prior
        if (!nrow(p_prec))  p_prec <- prec_prior
        
        c_truth <- sel[vartype == 'truthiness'      & st_or_ag == st]
        c_prec  <- sel[vartype == 'agent_precision' & st_or_ag == ag]
        if (!nrow(c_truth)) c_truth <- truth_prior
        if (!nrow(c_prec)) c_prec <- prec_prior

        f_truth <- truth_final[statement == st]
        f_prec  <-  prec_final[agent == ag]
        if (!nrow(f_truth)) f_truth <- truth_prior
        if (!nrow(f_prec)) f_prec <- prec_prior

        innovation <- wasserstein1d(p_truth[, value], ans$answer)
        miss <- wasserstein1d(f_truth[, value], ans$answer)
        shift <- wasserstein1d(p_truth[, value], f_truth[, value])

        if (((innovation + miss) >= shift) & ((miss + shift) >= innovation) & ((shift + innovation) >= miss)) {
            score <- (innovation^2 + shift^2 - miss^2) / (2 * shift)
        } else score <- NA_real_

        ll <- likelihoods[ll_iter == ans$iter]

        dat <- list(p_truth=p_truth, p_prec=p_prec, c_truth=c_truth, c_prec=c_prec,
                    f_truth=f_truth, f_prec=f_prec, ans=ans, st=st, ag=ag,
                    innovation=innovation, miss=miss, shift=shift, score=score,
                    likelihood = ll)

        return(dat)
    })

    
    ## * Posteriors
    output$plot_dist <- renderPlot({

        dat <- three_versions()
        
        col_t <- '#4DAF4A'
        col_p <- '#377EB8'

        lim_t <- c(0, 1)
        lim_p <- c(0, max(c(dat$p_prec$value, dat$c_prec$value, dat$f_prec$value)))

        ans <- answer()
        t_real <- real_truth[st_or_ag == ans$statement, value]
        p_real <- real_prec[st_or_ag == ans$agent, value]
        
        plot_truth <- function(d, type) {
            ggplot(d, aes(x = value)) +
                geom_density(aes(y = ..scaled..), fill=col_t, colour=NA, alpha=0.9) +
                geom_vline(xintercept = t_real, colour = 'white', linetype = 3) +
                geom_vline(xintercept = dat$ans$answer, colour='red') +
                scale_x_continuous(limits = lim_t) + theme_minimal() + mytheme() +
                labs(x = NULL, y = NULL, title = paste0(type, ' truthiness'))
                
        }
        plot_prec <- function(d, type) {
            ggplot(d, aes(x = value)) +
                geom_density(aes(y = ..scaled..), fill=col_p, colour=NA, alpha=0.9) +
                geom_vline(xintercept = p_real, colour = 'white', linetype = 3) +
                scale_x_continuous(limits = lim_p) + theme_minimal() + mytheme() +
                labs(x = NULL, y = NULL, title = paste0(type, ' precision'))
        }
        pt <- plot_truth(dat$p_truth, 'Previous')
        pp <- plot_prec(dat$p_prec, 'Previous')

        ct <- plot_truth(dat$c_truth, 'Updated')
        cp <- plot_prec(dat$c_prec, 'Updated')

        ft <- plot_truth(dat$f_truth, 'Final')
        fp <- plot_prec(dat$f_prec, 'Final')

        plot_grid(pt, pp, ct, cp, ft, fp, ncol=2)
        
    })

    ## * Likelihood plots
    output$ll_plots <- renderPlot({
        dat <- three_versions()
        req(dat)

        ll <- dat$likelihood
        ll <- rbind(ll[, .(type = 'At response time', value = ll_curr)],
                    ll[, .(type = 'Final', value = ll_final)])

        g <- ggplot(ll, aes(x = value, fill = type)) +
            geom_density(alpha=0.5) + mytheme() +
            scale_fill_discrete(name = NULL) +
            labs(x = 'Log-likelihood', y = 'Density')

        return(g)

    })
       
    ## * Score triangle
    output$plot_triangle <- renderPlot({

        dat <- three_versions()
        req(dat)

        Iv <- dat$innovation
        Fs <- dat$miss
        Sf <- dat$shift
        
        if (!(((Iv + Fs) >= Sf) & ((Fs + Sf) >= Iv) & ((Sf + Iv) >= Fs))) {
            warning('Impossible triangle')
            return(NULL)
        }

        IS <- c(0, 0)
        FS <- c(Sf, 0)

        a_IS <- acos((Iv^2 + Sf^2 - Fs^2) / (2 * Iv * Sf))
        a_FS <- acos((Fs^2 + Sf^2 - Iv^2) / (2 * Fs * Sf))

        FI <- c(IS[1] + Iv * Re(exp((0+1i) * a_IS)),
                IS[2] + Iv * Im(exp((0+1i) * a_IS)))

        lI <- c(IS[1] + 0.5 * Iv * Re(exp((0+1i) * a_IS)),
                IS[2] + 0.5 * Iv * Im(exp((0+1i) * a_IS)))

        lS <- c(Sf/2, 0)

        lF <- lI
        lF[1] <- lF[1] + Sf/2

        xr <- range(c(IS[1], FS[1], FI[1]))
        yr <- range(c(IS[2], FS[2], FI[2]))

        sides <- as.data.table(rbind(IS, FS, FI, IS))
        setnames(sides, c('x', 'y'))

        labs <- as.data.table(rbind(lI, lS, lF))
        setnames(labs, c('x', 'y'))
        labs[, lab := c(sprintf('Innovation\n%0.4f', Iv),
                        sprintf('Shift\n%0.4f', Sf),
                        sprintf('Miss\n%0.4f', Fs))]
        labs[, hadj := c(0.5, 0.5, 0.5)]
        labs[, vadj := c(0.5, 0, 0.5)]
        
        g <- ggplot() +
            geom_polygon(aes(x = x, y = y), data = sides, fill='grey50', colour='grey90') +
            geom_segment(x = dat$score, xend = dat$score, y = 0, yend = FI[2], colour='red') +
            geom_vline(xintercept = dat$score, colour='red') +
            coord_equal(clip = 'off') +
            labs(x = NULL, y = NULL, title = 'Score triangle') +
            geom_label(data = labs, aes(x = x, y = y, label = lab), hjust=labs$hadj, vjust=labs$vadj,
                       colour = 'white', fill = 'grey10', size=5, lineheight=0.9) +
            ## annotate(geom='label', x = dat$score, y = 0, label = sprintf('Score\n%0.4f', dat$score),
            ##          hjust=0.5, vjust = 1, colour = 'white', fill = 'red', size = 5) +
            theme(plot.background=element_rect(fill='#283639', colour = NA),
                  panel.background=element_rect(fill='#283639', colour = NA),
                  plot.title = element_text(colour = 'grey90'),
                  axis.line.x.bottom=element_line(colour = 'grey40'),
                  axis.line.y.left=element_line(colour = 'grey40'),
                  axis.text=element_text(colour = 'grey40'),
                  axis.ticks=element_line(colour = 'grey40')
                  )
        return(g)
        
    }, bg='#283639')
        
    ## output$score_txt <- reactive({
    ##     req(three_versions())
    ##     dat <- three_versions()
    ##     sprintf('<h2><div style="text-align: center;">SCORE: <b>%0.4f</b></div></h2>', dat$score)
    ## })

    output$score_txt2 <- reactive({
        req(three_versions())
        dat <- three_versions()
        sprintf('<div style="text-align: center;">Innovation: %0.4f<br>Miss: %0.4f<br>Shift: %0.4f</div>',
                dat$innovation, dat$miss, dat$shift)
    })
    
})
