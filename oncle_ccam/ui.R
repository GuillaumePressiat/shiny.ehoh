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
    titlePanel("Oncle Ccam, listes de codes CCAM des manuels de GHM"),
    
    
    tabsetPanel(
      # Guide ----
      

      tabPanel("Version de groupage",
               fluidRow(
                 column(10,selectInput("an", label = h3("Choisir la version"), 
                                       choices = list("2019" = 19,  "2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                                       selected = 19)))),
      
#h6("Cliquer", a("ici", href="http://164.1.196.52:3838"), "pour un retour à la page d'accueil de la plateforme"),
      mainPanel(width = 12,
                tabsetPanel(
                  tabPanel("Guide d'utilisation",
                           column(10, includeMarkdown("README_app.md"))),
                  
      tabPanel("Hiérarchie",
               fluidRow(
                 column(12, DT::dataTableOutput('df1')))),
      
      tabPanel("Ccam",
               fluidRow(
                 column(12, DT::dataTableOutput('df2')))),
      
      tabPanel("Listes Manuel GHM",
               fluidRow(
                 column(12, DT::dataTableOutput('listes')))),

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
               DT::dataTableOutput('datappartient'))
      # tabPanel("Reshape",
      #          h3('Pour passer une liste en ligne à une liste en colonne'),
      #          textInput("listi", "liste", "HHFA001, HHFA011, HHFA016, HHFA020, HHFA025"),
      #          h3('Liste bis'),
      #          #actionButton("copyButton2a", "Copie liste"),
      #          uiOutput("clip2"), 
      #          #verbatimTextOutput('cliste')
      #          verbatimTextOutput('ll2'))
    )
  )
)))
