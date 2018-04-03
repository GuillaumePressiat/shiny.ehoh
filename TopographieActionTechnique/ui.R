

library(shiny)

library(shinythemes)
shinyUI(
  
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Dico CCAM : Topographie Action Technique"),
    h6("Cliquer", a("ici", href="http://164.1.196.52:3838"), "pour un retour à la page d'accueil de la plateforme"),
    tabsetPanel(
      tabPanel("Présentation",
               column(10, includeMarkdown("README_app.md"))),
      
      
      tabPanel("Pour un acte en particulier",
               textInput("code", "", "Ahah001"), 
               tags$head(tags$style(HTML("#acte_topo tr.selected, #acte_topo tr.selected {background-color:red}"))),

              h3('Topographie'),
               
               fluidPage(DT::dataTableOutput('acte_topo')),
               
               h3('Action'),
               fluidPage(DT::dataTableOutput('acte_acti')),
               
               h3('Technique'),
               fluidPage(DT::dataTableOutput('acte_techn'))),
      
      tabPanel("Topographie",
               fluidRow(
                 column(12, DT::dataTableOutput('topographie')))),
      tabPanel("Action",
               fluidRow(
                 column(12, DT::dataTableOutput('action')))),
      tabPanel("Technique",
               fluidRow(
                 column(12, DT::dataTableOutput('technique'))))
  )
))
