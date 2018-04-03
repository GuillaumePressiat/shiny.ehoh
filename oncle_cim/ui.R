library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
library(readr)
#library(rclipboard)
library(zeroclipr)

shinyUI(

  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Oncle Cim, listes de codes CIM-10 des manuels de GHM ATIH"),
    
    
    
    tabsetPanel(
      tabPanel("Version de groupage",
               fluidRow(
                 column(10,selectInput("an", label = h3("Choisir la version"), 
                                       choices = list("2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                                       selected = 18)))),
      #h6("Cliquer", a("ici", href="http://164.1.196.52:3838"), "pour un retour à la page d'accueil de la plateforme"),
      mainPanel(width = 12,
                tabsetPanel(
      
      tabPanel("Guide d'utilisation",
               column(10, includeMarkdown("README_app.md"))),
      
      tabPanel("CIM-10",
               fluidRow(
                 column(12, DT::dataTableOutput('df')))),
      
      tabPanel("Listes manuel GHM",
               fluidRow(
                 column(12, DT::dataTableOutput('liste')))),
      
               tabPanel("Générer une liste",
#                         h3('Taper une racine de diagnostics'),
#                         textInput("caption", "Diag", "A00"), 'Entrée',
#                         h4('Liste de diagnostics'),

#                         actionButton("copyButton1a", "Copie tab"),
#                         actionButton("copyButton1b", "Copie liste"),
#                         actionButton("copyButton1c", "Copie quotes"),
                       
# uiOutput("clip2"),
    #                     verbatimTextOutput("value"),

#                         br(),
                        h3('Taper un numéro liste de diagnostics du manuel de GHM ou \'CMDxx\''),
                        textInput("num", "Num", "0101"),
                        #h4('Nom de la liste'),
                        #verbatimTextOutput('nliste'),
                        #h4('Catégorie Majeure de diagnostics'),
                        #verbatimTextOutput('cmdliste'),
                        h4('Liste de diagnostics'),
#                         actionButton("copyButton2a", "Copie tab"),
                        #tags$head(tags$script(src = "message-handler.js")),
                        #actionButton("copyButton2b", "Copie liste"),
                        uiOutput("clip"), 
                        verbatimTextOutput('cliste'),
                        h4('Sous forme de table, libellés'),
                        DT::dataTableOutput('dflib')),

tabPanel("Appartenance",
         h3('Est-ce que ce diagnostic appartient à une liste ?'),
         textInput("listi", "Diagnostic CIM-10", "E43"),
         h3('Liste(s)'),
         DT::dataTableOutput('datappartient'))

# tabPanel("Reshape",
#          h3('Pour passer une liste en ligne à une liste en colonne'),
#          textInput("listi", "liste", "A000, A001, B002, B003"),
#          h3('Liste bis'),
#          #actionButton("copyButton2a", "Copie liste"),
#          uiOutput("clip2"), 
#          #verbatimTextOutput('cliste')
#          verbatimTextOutput('ll2')
#     )
# tabPanel("Reshape",
#          h3('Pour passer une liste en ligne à une liste en colonne'),
#          textInput("listi", "liste", "A000, A001"),
#          h3('Liste bis'),
#          uiOutput("clip2"), 
#          verbatimTextOutput('ll2'))
      
    
  )
))))
