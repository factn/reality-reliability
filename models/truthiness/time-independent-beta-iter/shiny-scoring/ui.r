library(data.table)
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinydashboard)
library(DT)
library(leaflet)
library(rhandsontable)

addResourcePath('data', 'data')

function(request) {
    
    loadingLogo <- function(href, src, loadingsrc, height = NULL, width = NULL, alt = NULL) {
        tagList(
            tags$head(
                     tags$script(
                              "setInterval(function(){
                     if ($('html').attr('class')=='shiny-busy') {
                     $('div.busy').show();
                     $('div.notbusy').hide();
                     } else {
                     $('div.busy').hide();
                     $('div.notbusy').show();
           }
         },100)")
         )
         , div(class = "busy",  
             img(src=loadingsrc, height = height, width = width, alt = alt))
         , div(class = 'notbusy',
               div(class = 'logo', "Truthiness"))
        )
    }

    ## useShinyjs()
    
    dashboardPage(
        title = "Truthiness",
        header = dashboardHeader(
            title = loadingLogo('http://www.google.co.nz',
                                'data/logo.png',
                                'data/out.gif')
        )

      , sidebar = dashboardSidebar(
                                 tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"))
                                 , uiOutput('iter')
                                 , fluidRow(column(4, actionButton('prevbutt', '<', width='100%')),
                                            column(4, h5('Answer')),
                                            column(4, actionButton('nextbutt', '>', width='100%')))
                                 , fluidRow(column(4, actionButton('prevbutts', '<<', width='100%')),
                                            column(4, h5('Statement')),
                                            column(4, actionButton('nextbutts', '>>', width='100%')))
                                 , fluidRow(column(4, actionButton('prevbutta', '<-', width='100%')),
                                            column(4, h5('Agent answer')),
                                            column(4, actionButton('nextbutta', '->', width='100%')))
                                   )
        
      , body = dashboardBody(width = 12
                           , useShinyjs()
                           , h2(htmlOutput('answer_txt'))
                           , br()
                           , fluidRow(
                                 column(7
                                      , h3('Effect of answer')
                                      , plotOutput('plot_dist', height='600px')
                                        ),
                                 column(5
                                      , h4(htmlOutput('score_txt2'))
                                      , br()
                                      , h3(htmlOutput('score_txt'))
                                      , br()
                                      , br()
                                      , hr()
                                      , plotOutput('plot_triangle')
                                        )
                             )
                           ## , verbatimTextOutput('somelog')
                             )
    )
}
