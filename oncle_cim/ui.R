library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
library(readr)
#library(rclipboard)
library(zeroclipr)

shinyUI(

  fluidPage(
    theme = shinytheme("lumen"),
    #titlePanel("Oncle Cim, listes de codes CIM-10 des manuels de GHM ATIH"),
    
    
    
    navbarPage(title = "Oncle CIM",
        
      tabPanel("Guide d'utilisation",
               column(8, 
                      h2("Guide d'utilisation / Année"),
                      includeMarkdown("README_app.md")),
                      column(4,
                             selectInput("an", label = h3("Choisir l'année séquentielle"), 
                           choices = list("2019" = 19,  "2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                           selected = 19))),
      
      tabPanel("CIM-10",
               fluidRow(
                 
                 column(12, 
                        
                        h6(strong("Types de restriction :"), "0 Pas de restriction - 1 Interdit en DP et en DR, autorisé ailleurs - 2 Interdit en DP et en DR, cause externe de morbidité - 3 interdit en DP, DR, DA - 4 Interdit en DP, autorisé ailleurs"),
                        DT::dataTableOutput('df')))),
      
      tabPanel("Listes manuel GHM",
               tabsetPanel(
                 tabPanel('Listes manuels',
                          fluidRow(
                 column(12, DT::dataTableOutput('liste')))),
               tabPanel("Générer une liste",
                    #verbatimTextOutput("value"),

                        h3('Taper un numéro liste de diagnostics du manuel de GHM ou \'CMDxx\''),
                        textInput("num", "Num", "0101"),
                        h4('Liste de diagnostics'),
                        uiOutput("clip"), 
                        verbatimTextOutput('cliste'),
                        h4('Sous forme de table, libellés'),
                        DT::dataTableOutput('dflib')),

tabPanel("Appartenance",
         h3('Est-ce que ce diagnostic appartient à une liste ?'),
         textInput("listi", "Diagnostic CIM-10", "E43"),
         h3('Liste(s)'),
         DT::dataTableOutput('datappartient'))))

     
    
  )
))
