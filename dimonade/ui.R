library(shiny)
library(dplyr)
library(stringr)
library(shinythemes)

poss <-c("0 Pas de restriction",
         "1 Interdit en DP et en DR, autorisé ailleurs",
         "2 Interdit en DP et en DR, cause externe de morbidité", 
         "3 interdit en DP, DR, DA", 
         "4 Interdit en DP, autorisé ailleurs")

shinyUI(
  fluidPage(
    theme = shinytheme("lumen"),
    tags$style(HTML("
      .label {
      background-color: #e6e6e6;
      color:black;
      font-size:110%;
      /*border-color: grey;
      border-width:thin;
      border-radius: .25em;
      border-style: solid;
      color: black;
      
      padding: .4em;*/
      }
    ")),
    tags$style(HTML(".js-irs-0 .irs-single, .js-irs-0 .irs-bar-edge, .js-irs-0 .irs-bar {background: #cccccc; border:white; color:black}")),
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
                                                                  shinyWidgets::checkboxGroupButtons(inputId = "niveau_hiera_ccam",
                                                                                                     label = "Niveau hiérarchique",
                                                                                                     choiceNames = c('1 - Chapitre', '2 - Sous-chapitre', '3 - Paragraphe', '4 - Sous-paragraphe'),
                                                                                                     choiceValues = c('1 - Chapitre', '2 - Sous-chapitre', '3 - Paragraphe', '4 - Sous-paragraphe'),
                                                                                                     selected = c('1 - Chapitre', '2 - Sous-chapitre', '3 - Paragraphe', '4 - Sous-paragraphe')), 
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
                        tabsetPanel(selected = "Hiérarchie",
                                    tabPanel("Hiérarchie",
                                             fluidRow(
                                               br(),
                                               
                                               column(9,
                                               shinyWidgets::prettyRadioButtons('niveau_hiera', 'Niveau hiérarchique', choices = c('Catégorie', 'Bloc', 'Chapitre'), selected = 'Bloc', 
                                                                                shape = "round",animation = "jelly",plain = TRUE,bigger = TRUE,inline = TRUE,
                                                                                  
                                                                                fill = TRUE)),
                                               column(3,
                                               shinyWidgets::prettyCheckbox('regexp_cim', 'Aide expressions régulières', status = 'primary')),
                                               column(12, 
                                                      DT::dataTableOutput('cim_hiera_df')))),
                                    tabPanel("CIM",
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
                                 ))),
               tabPanel('Fabrique  à liste',
                        br(),
                        shinyjs::useShinyjs(),
                        fluidRow(
                            column(3, textInput("text", "Filtrer sur les codes", width = '400px',
                                                placeholder = 'H[6-9][0-5], e4')),
                          column(2, shinyWidgets::radioGroupButtons(inputId = 'nomenclature', label = c('Nomenclature'), choices = c('CIM', 'CCAM'), individual = TRUE))),
                        shinyWidgets::checkboxGroupButtons(inputId = "positions",
                                                           label = "Positions des diagnostics", 
                                                           choiceNames = poss,
                                                           choiceValues = as.character(0:4),
                                                           selected = as.character(c(0,1,2,3,4))),
                        uiOutput('variables'),
                        tags$h5("Déplacer les codes pères pour filtrer la liste"),
                        uiOutput('var2', width = "100%", height = 150),
                        
                        fluidRow(
                          column(3,
                                 shinyWidgets::switchInput("code_pere", label = "Type liste", value = FALSE, onLabel = "Catégories", offLabel = "Codes CIM", size = "mini")),
                          column(6, shinyWidgets::prettyRadioButtons('format_liste', label = NULL, 
                                                                     choices = c('nu', 'simple quote', 'double quote', 'pipe', 'SQL like%'), selected = 'nu', 
                                                                     inline = TRUE, fill = TRUE, bigger = TRUE)), 
                          column(2, textInput('sep_l', 'Séparateur', value = ', ', width = 150)),
                          column(1, checkboxInput('wrapof', label = 'Wrap', value = FALSE),
                          shinyjs::hidden(numericInput('wrapw', label = NULL, min = 30, max = 1e6, value = 90)))), 
    h6('Astuce : pour copier la liste triple clic + copier'),
    verbatimTextOutput('liste'),
                        DT::dataTableOutput('diags2')
               ))))
  
               