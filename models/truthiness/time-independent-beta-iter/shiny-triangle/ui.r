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
                                 , uiOutput('innovation')
                                 , uiOutput('foresight')
                                 , uiOutput('shift')
                                   )
        
      , body = dashboardBody(width = 12
                           , useShinyjs()
                           , h3(htmlOutput('score_txt'))
                           , br()
                           , br()
                           , plotOutput('plot_triangle')
                             )
    )
}
