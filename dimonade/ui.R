library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("lumen"),
    navbarPage(title = "DiMonade",selected = "Oncle CCAM",
               tabPanel("Guide d'utilisation / Année",
                        column(8, 
                               h2("Guide d'utilisation"),
                               includeMarkdown("README_app.md")),
                        column(4,
                               selectInput("an", label = h3("Choisir l'année séquentielle"), 
                                           choices = list("2019" = 19,  "2018" = 18, "2017" = 17,"2016" = 16, "2015" = 15), 
                                           selected = 19))),
               
               tabPanel("Oncle CCAM",
                        tabsetPanel(selected = "CCAM",
                                    tabPanel("CCAM",
                                             br(),
                                             tabsetPanel(selected = "CCAM",
                                                         tabPanel('Hiérarchie',
                                                                  br(),
                                                                  DT::dataTableOutput('ccam_df1')),
                                                         tabPanel("CCAM",br(),
                                                                  DT::dataTableOutput('ccam_df2')),
                                                         tabPanel("Notes",br(),
                                                                  DT::dataTableOutput('ccam_df3')))),
                                    tabPanel("Listes Manuel GHM",
                                             br(),
                                               tabsetPanel(
                                                 tabPanel('Listes Manuels', br(), DT::dataTableOutput('ccam_listes')),
                                                 tabPanel("Générer une liste",
                                                          h3('Taper un numéro liste de diagnostics de manuel de GHM'),
                                                          textInput("ccam_num", "Num", "047"),
                                                          h4('Nom de la liste'),
                                                          verbatimTextOutput('ccam_nliste'),
                                                          h4('Liste de codes'),
                                                          #actionButton("copyButton2b", "Copie liste"),
                                                          uiOutput("ccam_clip"), 
                                                          verbatimTextOutput('ccam_cliste'),
                                                          h4('Sous forme de table, libellés'),
                                                          DT::dataTableOutput('ccam_dflib')),
                                                 tabPanel("Appartenance",
                                                          h3('Est-ce que cet acte appartient à une liste ?'),
                                                          textInput("ccam_listi", "Acte CCAM", "HHFA001"),
                                                          h3('Liste(s)'),
                                                          DT::dataTableOutput('datappartient_ccam')))),
                                             
                                             
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

                                    )),
               tabPanel("Oncle CiM",
                        tabsetPanel(selected = "CIM-10",
                                    tabPanel("CIM-10",
                                             fluidRow(
                                               
                                               column(12, 
                                                      
                                                      h6(strong("Types de restriction :"), "0 Pas de restriction - 1 Interdit en DP et en DR, autorisé ailleurs - 2 Interdit en DP et en DR, cause externe de morbidité - 3 interdit en DP, DR, DA - 4 Interdit en DP, autorisé ailleurs"),
                                                      DT::dataTableOutput('cim_df')))),
                                    
                                    tabPanel("Listes manuel GHM",
                                             br(),
                                             tabsetPanel(
                                               tabPanel('Listes manuels',
                                                        br(),
                                                        fluidRow(
                                                          column(12, DT::dataTableOutput('cim_liste')))),
                                               tabPanel("Générer une liste",
                                                        br(),
                                                        #verbatimTextOutput("value"),
                                                        
                                                        h3('Taper un numéro liste de diagnostics du manuel de GHM ou \'CMDxx\''),
                                                        textInput("cim_num", "Num", "0101"),
                                                        h4('Liste de diagnostics'),
                                                        uiOutput("cim_clip"), 
                                                        verbatimTextOutput('cim_cliste'),
                                                        h4('Sous forme de table, libellés'),
                                                        DT::dataTableOutput('cim_dflib')),
                                               
                                               tabPanel("Appartenance",
                                                        h3('Est-ce que ce diagnostic appartient à une liste ?'),
                                                        textInput("cim_listi", "Diagnostic CIM-10", "E43"),
                                                        h3('Liste(s)'),
                                                        DT::dataTableOutput('datappartient_cim'))))
                        )),
               tabPanel('Oncle GHM',
                        tabsetPanel(selected = "GHM ?",
                        tabPanel("GHM ?",
                                 textInput("GHM", "GHM :", "01C034"),
                                 h4('Libellé :'),
                                 verbatimTextOutput("ghm_lib"),
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
                                 br(),
                                 tabsetPanel(
                                   
                                   tabPanel("GHM",br(),
                                            fluidRow(DT::dataTableOutput('ghm_dflib1'))),
                                   
                                   tabPanel("Racines",br(),
                                            fluidRow(DT::dataTableOutput('ghm_dflib2'))))),
                        
                        tabPanel('Tarifs',
                                 br(),
                                 tabsetPanel(
                                   tabPanel("GHS",br(),
                                            fluidRow(DT::dataTableOutput('ghm_dflib3'))),
                                   tabPanel("Suppléments",br(),
                                            fluidRow(DT::dataTableOutput('ghm_dflib4'))))
                                 ))))))
  
               