library(shiny)
library(shinyWidgets)
library(shinyjs)
library(data.table)
library(shinydashboard)
library(ggplot2)
library(cowplot)

load('../generated/data.rdata', v=F)

source('../../functions.r')

options(warn = 1)

load('data/data.rdata')

mytheme <- function() {
    theme(plot.background=element_rect(fill='#283639', colour = NA),
          panel.background=element_rect(fill='#283639', colour = NA),
          panel.grid.major=element_line(colour = '#313E41FF'),
          panel.grid.minor=element_line(colour = '#2C3A3DFF'),
          axis.text.x = element_text(colour = 'grey70'),
          axis.text.y = element_text(colour = 'grey70'),
          plot.title = element_text(colour = 'grey90'))
}

input <- list(innovation = 0.7,
              foresight  = 0.3,
              shift      = 0.5
              )

## * SERVER
shinyServer(function(input, output, session) {

    output$innovation <- renderUI(sliderInput("innovation", label = "Innovation", min = 0, max = 1, step=0.01,
                                        value = 0.2))
    output$foresight <- renderUI(sliderInput("foresight", label = "Foresight", min = 0, max = 1, step=0.01,
                                        value = 0.2))
    output$shift <- renderUI(sliderInput("shift", label = "Shift", min = 0, max = 1, step=0.01,
                                        value = 0.2))

    stats <- reactive({
        req(input$innovation)
        req(input$foresight)
        req(input$shift)
        Iv <- input$innovation
        Fs <- input$foresight
        Sf <- input$shift

        if (((Iv + Fs) >= Sf) & ((Fs + Sf) >= Iv) & ((Sf + Iv) >= Fs)) {
            score <- (Iv^2 + Sf^2 - Fs^2) / (2 * Sf)
        } else score <- NA_real_

        return(list(innovation = Iv, foresight = Fs, shift = Sf, score = score))
    })

    output$plot_triangle <- renderPlot({

        req(stats())
        dat <- stats()
        Iv <- dat$innovation
        Fs <- dat$foresight
        Sf <- dat$shift
        score <- dat$score

        if (!(((Iv + Fs) >= Sf) & ((Fs + Sf) >= Iv) & ((Sf + Iv) >= Fs))) {
            warning('Impossible triangle')
            g <- ggplot() + ggtitle('Impossible triangle') +
                theme(plot.background=element_rect(fill='#CC0000', colour = NA),
                  panel.background=element_rect(fill='#CC0000', colour = NA),
                  plot.title = element_text(colour = 'white')
                  )
            return(g)
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
                        sprintf('Foresight\n%0.4f', Fs))]
        labs[, hadj := c(0.5, 0.5, 0.5)]
        labs[, vadj := c(0.5, 0, 0.5)]
        
        g <- ggplot() +
            geom_polygon(aes(x = x, y = y), data = sides, fill='grey50', colour='grey90') +
            geom_segment(x = dat$score, xend = dat$score, y = 0, yend = FI[2], colour='red') +
            geom_vline(xintercept = dat$score, colour='red') +
            coord_equal(clip = 'off') +
            labs(x = NULL, y = NULL, title = 'Score triangle') +
            ## theme_void() +
            geom_label(data = labs, aes(x = x, y = y, label = lab), hjust=labs$hadj, vjust=labs$vadj,
                       colour = 'white', fill = 'grey10', size=5, lineheight=0.9) +
            annotate(geom='label', x = dat$score, y = 0, label = sprintf('Score\n%0.4f', dat$score),
                     hjust=0.5, vjust = 1, colour = 'white', fill = 'red', size = 5) +
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
        
    output$score_txt <- reactive({
        req(stats())
        dat <- stats()
        sprintf('SCORE: <b>%0.4f</b>', dat$score)
    })
    
})
