library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
library(rmarkdown)

shinyUI(
  fluidPage(
    theme = shinytheme("lumen"),
    navbarPage(title = "Oncle GHM",
    
    
    tabPanel("Guide d'utilisation / Année",
             column(8, 
                    h2("Guide d'utilisation / Année"),
                    includeMarkdown("README_app.md")),
             column(4,
                    selectInput("an", label = h3("Choisir l'année séquentielle"), 
                                choices = list("2019" = 19,  "2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                                selected = 19))),
    
    # h6("Cliquer", a("ici", href="http://164.1.196.52:3838"), "pour un retour à la page d'accueil de la plateforme"),
    
      # Guide ----
      

      tabPanel("GHM ?",
               textInput("GHM", "GHM :", "01C034"),
               h4('Libellé :'),
               verbatimTextOutput("lib"),
               h4('Racine :'),
               verbatimTextOutput("racine"),
               h4("Domaine d'activité - activité de soins :"),
               verbatimTextOutput("da"),
               h4("Groupe de planification :"),
               verbatimTextOutput("gp"),
               h4("Groupe d'activité :"),
               verbatimTextOutput("ga"),
               h4("Informations tarifs :"),
               DT::dataTableOutput('tarifs')
               ),
      
    tabPanel('Regroupements',  
    tabsetPanel(

    tabPanel("RGP-GHM",br(),
               fluidRow(DT::dataTableOutput('dflib1'))),
      
      tabPanel("RGP-RGHM",br(),
               fluidRow(DT::dataTableOutput('dflib2'))))),
      
    tabPanel('Tarifs',
    tabsetPanel(
      tabPanel("GHS",br(),
               fluidRow(DT::dataTableOutput('dflib3'))),
      tabPanel("Suppléments",br(),
               fluidRow(DT::dataTableOutput('dflib4')))))
)))
