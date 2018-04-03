library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)
library(rmarkdown)

shinyUI(
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("GHM, RGHM, GHS, libellés et regroupements"),
    
    tabsetPanel(
      tabPanel("Version de classification", 
               selectInput("an", label = h3("Sélectionner l'année :"), 
                                         choices = list("2018" = 18, "2017" = 17,"2016" = 16, "2015 (v11g)" = 15), 
                                         selected = 17))),
    # h6("Cliquer", a("ici", href="http://164.1.196.52:3838"), "pour un retour à la page d'accueil de la plateforme"),
    mainPanel(width = 12,
    tabsetPanel(
      # Guide ----
      
      tabPanel("Guide d'utilisation",
               includeMarkdown("README_app.md")),
      
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
      
      tabPanel("RGP-GHM",
               fluidRow(DT::dataTableOutput('dflib1'))),
      
      tabPanel("RGP-RGHM",
               fluidRow(DT::dataTableOutput('dflib2'))),
      
      tabPanel("GHS",
               DT::dataTableOutput('dflib3')),
      tabPanel("Suppléments",
               DT::dataTableOutput('dflib4'))
))))
