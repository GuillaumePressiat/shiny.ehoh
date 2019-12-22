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
    navbarPage(title = "Oncle CCAM",
               
      tabPanel("Guide d'utilisation",
               includeMarkdown("README_app.md")),
      
      tabPanel("CCAM",
               tabsetPanel(selected = "CCAM",
                 tabPanel('Hiérarchie',
                          br(),
                          DT::dataTableOutput('df1')),
                 tabPanel("CCAM",br(),
                          DT::dataTableOutput('df2')),
               tabPanel("Notes",br(),
                        DT::dataTableOutput('df3')))),
      
      

      tabPanel("Listes Manuel GHM",
               selectInput("an", label = h5("Choisir l'année séquentielle des tarifs"), 
                             choices = list("2019" = 19,  "2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                             selected = 19),
               tabsetPanel(#widths = c(3,9),
                 tabPanel('Listes Manuels', br(), DT::dataTableOutput('listes')),
                 tabPanel("Générer une liste",
               h3('Taper un numéro liste de diagnostics de manuel de GHM'),
               textInput("num", "Num", "047"),
               h4('Nom de la liste'),
               verbatimTextOutput('nliste'),
               h4('Liste de codes'),
               #actionButton("copyButton2b", "Copie liste"),
               uiOutput("clip"), 
               verbatimTextOutput('cliste'),
               h4('Sous forme de table, libellés'),
               DT::dataTableOutput('dflib')),
               tabPanel("Appartenance",
                        h3('Est-ce que cet acte appartient à une liste ?'),
                        textInput("listi", "Acte CCAM", "HHFA001"),
                        h3('Liste(s)'),
                        DT::dataTableOutput('datappartient')))),
      

      
      tabPanel("Dico CCAM",
               br(),
               # hr(),
               navlistPanel(widths = c(3,9),
        tabPanel("Présentation", 
                 column(10, includeMarkdown("README_app_dico.md"))),
        
        
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
                   column(12, DT::dataTableOutput('technique'))))))
      

    )
  ))

