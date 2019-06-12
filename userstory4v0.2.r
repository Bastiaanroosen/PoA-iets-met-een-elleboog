# Laden van de packages
library(DBI)
library(RMySQL)
library(dplyr)
library(ggplot2)
library(plotly)

waterstanden_jac <- subset(waterstanden1, datumtijd > as.POSIXct("2018-01-01 00:00:00"))
waterstanden_jac[waterstanden_jac == ""] <- NA
waterstanden_jac_clean <- na.omit(waterstanden_jac)

df_havens <- select(waterstanden_jac_clean, c(BUITENHUIZEN, SURINAME, HAGESTEIN, IJMUIDENBUITEN, IJMUIDENSTROOM))
df_tijden <- select(waterstanden_jac_clean, c(datumtijd, WAARNEMINGDATUM))

m01 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-01-01 00:00:00"))
m01 <- subset(m01, datumtijd < as.POSIXct("2018-02-01 00:00:00"))
m02 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-02-01 00:00:00"))
m02 <- subset(m02, datumtijd < as.POSIXct("2018-03-01 00:00:00"))
m03 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-03-01 00:00:00"))
m03 <- subset(m03, datumtijd < as.POSIXct("2018-04-01 00:00:00"))
m04 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-04-01 00:00:00"))
m04 <- subset(m04, datumtijd < as.POSIXct("2018-05-01 00:00:00"))
m05 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-05-01 00:00:00"))
m05 <- subset(m05, datumtijd < as.POSIXct("2018-06-01 00:00:00"))
m06 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-06-01 00:00:00"))
m06 <- subset(m06, datumtijd < as.POSIXct("2018-07-01 00:00:00"))
m07 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-07-01 00:00:00"))
m07 <- subset(m07, datumtijd < as.POSIXct("2018-08-01 00:00:00"))
m08 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-08-01 00:00:00"))
m08 <- subset(m08, datumtijd < as.POSIXct("2018-09-01 00:00:00"))
m09 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-09-01 00:00:00"))
m09 <- subset(m09, datumtijd < as.POSIXct("2018-10-01 00:00:00"))
m10 <- subset(waterstanden_jac_clean, datumtijd > as.POSIXct("2018-10-01 00:00:00"))
m10 <- subset(m10, datumtijd < as.POSIXct("2018-11-01 00:00:00"))

library(shiny)

ui <- fluidPage(
headerPanel('User Story 4: Jacques Scorea'),
  sidebarPanel(
    
    selectInput('xcol', 'Datum', names(df_tijden),
    selected = names(df_tijden)[[1]]),
    selectInput('ycol', 'Locaties', names(df_havens),
    selected = names(df_havens)[[1]]),
    fluidRow(box(sliderInput("maand", "Data per maand", 1,10,1,1)))
),
mainPanel(
    plotlyOutput('plot1'),
    plotlyOutput('plot2')
)
)

server <- function(input, output) {
  
    output$plot1 <- renderPlotly({
    p <- ggplot(waterstanden_jac_clean, aes(x=waterstanden_jac_clean[ , input$xcol],y= waterstanden_jac_clean[ , input$ycol])) + geom_line()
    p + labs(x = "Datum", y = "Locatie" )
})
    
    output$plot2 <- renderPlotly({
    maand <- switch(
    input$maand,
    m01,
    m02,
    m03,
    m04,
    m05,
    m06,
    m07,
    m08,
    m09,
    m10
)
    p <- ggplot(maand, aes(x=maand[ , input$xcol],y= maand[ , input$ycol])) + geom_line()
    p + labs(x = "Datum", y = "Locatie" )
})
}
shinyApp(ui = ui, server = server)
