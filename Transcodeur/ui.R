
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(stringr)
library(shiny)
library(shinythemes)

shinyUI(fluidPage(
  theme = shinytheme("cosmo"),
  # Application title
  titlePanel("Transcodeur"),
  div(style="display:inline-block",
                selectInput("qu", label = h3("Choisir le signe"), 
              choices = list("Quote" = '\'', "Guillemet" = '\"', 'Aucun' = '¨'), 
              selected = '\'')),
  div(style="display:inline-block",
      selectInput("sepi", label = h3("Séparateur (ligne)"), 
              choices = list("`, ` : virgule espace" = ', ', "` ` : espace" = ' ', "`,` : virgule" = ','), 
              selected = ', ')),
  tabsetPanel(
    
    tabPanel("Transcode lignes",fluidRow(
      column(12,
             selectInput("type", label = h3("Choisir le type de liste en retour"), 
                                      choices = list("SAS" = 'SAS', "SQL %Like%" = 'SQL', "Pipe R" = 'Pipe'), 
                                      selected = 'SAS'),

                            h3('Taper une liste de codes'),
                            textInput("listi", "Clic, ctrl + A pour sélectionner + ctrl V pour coller", "F072, G430, G431, G432, G433, G438, G439, G440, G441, G442, G443, G444, G448, G932, G971, R51", width = "500px"),
                            verbatimTextOutput('ll2'),
                            h6('- astuce : triple clic + ctrl c pour copier'))
             )),
  
  tabPanel("Transcode colonnes",fluidRow(
    column(12,
           selectInput("type2", label = h3("Choisir le type de liste en retour"), 
                       choices = list("SAS" = 'SAS', "SQL %Like%" = 'SQL', "Pipe R" = 'Pipe'), 
                       selected = 'SAS'),
    h3('Taper une liste de codes'),
    textAreaInput("listi2", "Clic, ctrl + A pour sélectionner + ctrl V pour coller", "BGBA001\nBGDA001\nBGDA002\nBGDA003\nBGDA004\nBGDA005\nBGDA006\nBGDA007\nBGDA008\nBGFA002\nBGFA003\nBGFA004", width = "150px", height = "250px"),
    verbatimTextOutput('ll3'),
    h6('- astuce : triple clic + ctrl c pour copier'))
  )),
  
  #tabPanel(HTML("ligne 	&#x21CC;  colonne"),fluidRow(
  tabPanel(HTML("ligne 	&#x21D4;  colonne"),fluidRow(
    column(12,
           selectInput("type3", label = h3("Choisir le type de transposition"), 
                       choices = list("colonne > ligne" = "colonne > ligne", "ligne > colonne" = "ligne > colonne"), 
                       selected = "colonne > ligne"),
    h3('Taper une liste de codes'),
    textAreaInput("listi3", "Clic, ctrl + A pour sélectionner + ctrl V pour coller", "BGBA001\nBGDA001\nBGDA002\nBGDA003\nBGDA004\nBGDA005\nBGDA006\nBGDA007\nBGDA008\nBGFA002\nBGFA003\nBGFA004\nBGFA005\nBGFA006\nBGFA007\nBGFA009\nBGFA010\nBGJA001\nBGJA002\nBGJB001\nBGLP001\nBGMA001\nBGMA002\nBGMA003\nBGNA001\nBGNP005\nBGPA001\nBGPA002\nBGPA003\nBGPP001\nBGRF001", width = "500px", height = "250px"),
    verbatimTextOutput('ll4'),
    h6('- astuce : triple clic + ctrl c pour copier'))
  ))
)))
