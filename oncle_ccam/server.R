library(shiny)
library(dplyr)
library(stringr)
library(DT)
#library(clipr)
library(readr)
#library(rclipboard)
library(zeroclipr)
library(rmarkdown)

read_rds('ccam15.Rds') -> ccam15
read_rds('ccam16.Rds') -> ccam16
read_rds('ccam17.Rds') -> ccam17
read_rds('ccam18.Rds') -> ccam18
read_rds('ccam19.Rds') -> ccam19

read_rds('notes15.Rds') -> notes15
read_rds('notes16.Rds') -> notes16
read_rds('notes17.Rds') -> notes17
read_rds('notes18.Rds') -> notes18
read_rds('notes19.Rds') -> notes19

read_rds('hierarchie15.Rds') -> hierarchie15
read_rds('hierarchie16.Rds') -> hierarchie16
read_rds('hierarchie17.Rds') -> hierarchie17
read_rds('hierarchie18.Rds') -> hierarchie18
read_rds('hierarchie19.Rds') -> hierarchie19

read_rds('listes15.Rds') -> listes15
read_rds('listes16.Rds') -> listes16
read_rds('listes17.Rds') -> listes17
read_rds('listes18.Rds') -> listes18
read_rds('listes19.Rds') -> listes19

readr::read_rds('topographie.Rds') %>%  dplyr::select( Code = Code2, `Code Site Ana.` = Code, dplyr::everything()) ->topographie
readr::read_rds('action.Rds') -> action
readr::read_rds('technique.Rds') -> technique


shinyServer(function(input, output){

  
  output$value <- renderPrint({
    dataset <- datasetInput()
    cat(as.character(dataset$code), sep = ', ')
    })

 # voir la table
  output$df2 <- DT::renderDataTable(distinct(get(paste0('ccam',input$an)) %>% 
                                      select(`Code CCAM / ATIH` = code,
                                             #`Code hiérarchie` = parent,
                                             `Strate CCAM` = strate,
                                             `Libellé` = libelle,
                                             `Date de début` = date_debut,
                                             `Date de fin` = date_fin)),
                                   filter = 'top',
                                   options = list(pageLength = 20,
                                                  searchHighlight = TRUE, 
                                                  search = list(regex = TRUE)),
                                   rownames = FALSE, server = TRUE)
  
  output$df1 <- DT::renderDataTable(get(paste0('hierarchie',input$an)) %>% 
                                      select(`Niveau hiérarchique` = niveau,
                                             #`Code hiérarchie` = code,
                                             `Strate CCAM` = strate,
                                             `Libellé` = libelle,
                                             `Chapitre` = libelle_niveau_1,
                                             `Sous-chapitre` = libelle_niveau_2,
                                             `Paragraphe` = libelle_niveau_3,
                                             `Sous-paragraphe` = libelle_niveau_4) %>% 
                                      mutate(`Niveau hiérarchique` = as.factor(case_when(
                                        `Niveau hiérarchique` == 1 ~ '1 - Chapitre',
                                        `Niveau hiérarchique` == 2 ~ '2 - Sous-chapitre',
                                        `Niveau hiérarchique` == 3 ~ '3 - Paragraphe',
                                        `Niveau hiérarchique` == 4 ~ '4 - Sous-paragraphe'))),
                                   filter = 'top',
                                   options = list(searchHighlight = TRUE, pageLength = 20),
                                   rownames = FALSE, server = TRUE)
  
  output$df3 <- DT::renderDataTable(distinct(get(paste0('notes',input$an)) %>% 
                                               tidyr::unite(`Type note`, type_note, libelle_type_note, sep = " - ") %>% 
                                               select(`Code CCAM` = code,
                                                      `Type note`,
                                                      Note = note,
                                                      `Date de début` = date_debut)),
                                    filter = 'top',
                                    options = list(pageLength = 20,
                                                   searchHighlight = TRUE, 
                                                   search = list(regex = TRUE)),
                                    rownames = FALSE, server = TRUE)
  # Voir les listes
  output$listes <- DT::renderDataTable(distinct(select(get(paste0('listes',input$an)),`N° de liste` = num_liste, 
                                                       `Nom de la liste` = d, `Racines ghm` = rghm, `CM (D)` = cmd )), 
                                       server = TRUE,
                                      filter = 'top',
                                      rownames = FALSE,
                                      options = list(
                                        searchHighlight = TRUE, 
                                          pageLength = 20,
                                        autoWidth = F))
  
  # Diags des listes 
  clistet <- reactive({
    get(paste0('listes',input$an)) %>% filter(num_liste == input$num) %>% 
      distinct(acte, .keep_all = T) %>% mutate(acte = str_trim(acte))
  })
  
  
  output$nliste <- renderPrint({
    dataset <- clistet()
    cat(unique(paste0(dataset$num_liste,' - ', dataset$d)))
  })
  
  output$cliste <- renderPrint({
    dataset <- clistet()
    cat(as.character(unique(dataset$acte)), sep = ', ')
  })
  
  observeEvent(input$copyButton2b, {
    dataset <- clistet()
    clipr::write_clip(toString(unique(dataset$acte)))
  })
  
  output$ll2 <- reactive({
    ll <- input$listi
    as.character(str_replace_all(ll, "\\,\\s", "\r\n"))
    })
#   observeEvent(input$copyButton2a, {
#     ll <- input$listi
#     clipr::write_clip(as.character(str_replace_all(ll, "\\,\\s", "\r\n")))
#   })

# output$clip2 <- renderUI({
#   ll <- input$listi
#   str <- textConnection("te", open = "w")
#   write.table(as.character(str_replace_all(ll, "\\,\\s", "\r\n")), str, 
#               quote = F, row.names = FALSE, col.names = F)
#   close(str)
#   zeroclipButton("clipbtn", "Copie Tab", te, icon("clipboard"))
# })
  clistetlib <- reactive({
    get(paste0('listes',input$an)) %>% filter(num_liste == input$num) %>%
      distinct(acte,  acte_descr, libelle, d, rghm, cmd, date_debut, date_fin) %>% 
      select(`Acte CCAM` = acte, `Acte ATIH` = acte_descr, libelle, nom_liste = d, rghm, cmd, date_debut, date_fin)
  })
  
  output$dflib <- DT::renderDataTable(datatable(
    clistetlib(), extensions = 'Buttons', options = list(
      pageLength = nrow(clistetlib()),
      dom = 'Bfrtip',
      buttons = c('copy' , 'print')
    ), rownames = F
  ),server = F)
  
  appartient <- reactive({
    get(paste0('listes',input$an)) %>% filter(acte == input$listi) %>% 
      distinct(num_liste, .keep_all = T) %>% select(Acte = acte, 
                                                    `Acte ATIH` = acte_descr,
                                                    `Nom de la liste`= d, `N° liste` = num_liste, `CM (D)` = cmd, `Racines ghm` = rghm)
  })
  
  output$datappartient <- DT::renderDataTable(datatable(appartient(), options = list(
    pageLength = nrow(appartient()))))
  
 output$clip <- renderUI({
   
   str <- textConnection("te", open = "w")
   write.table(paste0(as.character(clistet()$acte), collapse = ", "), str, 
               quote = F, row.names = FALSE, col.names = F)
   close(str)
   zeroclipButton("clipbtn", "Copie Liste", te, icon("clipboard"))
 })

 
 
 
 acte_topo1 <-   reactive({
   unique(topographie[topographie$Code == substr(toupper(input$code),1,2),])
 })
 
 
 output$acte_topo <-   DT::renderDataTable(DT::datatable(acte_topo1(), rownames = FALSE, extensions = 'Scroller', options = list(scrollY = 40,
                                                                                                               scroller = TRUE,  dom = 't',
                                                                                                               autoWidth = TRUE,
                                                                                                               columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
                                             DT::formatStyle('Code', backgroundColor = 'grey', color = 'white'))
 
 
 acte_acti1 <-   reactive({
   unique(action[action$Code == substr(toupper(input$code),3,3),])
 })
 
 
 output$acte_acti <-   DT::renderDataTable(DT::datatable(acte_acti1(), rownames = FALSE, extensions = 'Scroller', options = list(scrollY = 160,
                                                                                                               scroller = TRUE,  dom = 't',
                                                                                                               autoWidth = TRUE,
                                                                                                               columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
                                             DT::formatStyle('Code', backgroundColor = 'grey', color = 'white'))
 
 acte_techn1 <-   reactive({
   unique(technique[technique$Code == substr(toupper(input$code),4,4),])
 })
 
 
 output$acte_techn <-   DT::renderDataTable(DT::datatable(acte_techn1(), rownames = FALSE, extensions = 'Scroller', options = list(scrollY = 160,
                                                                                                                 scroller = TRUE,  dom = 't',
                                                                                                                 autoWidth = TRUE,
                                                                                                                 columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
                                              DT::formatStyle('Code', backgroundColor = 'grey', color = 'white'))
 
 
 output$topographie <- DT::renderDataTable(topographie,
                                           filter = 'top',
                                           rownames = FALSE, server = TRUE,
                                           options = list(pageLength = nrow(topographie)))
 
 output$action <- DT::renderDataTable(action,
                                      filter = 'top',
                                      rownames = FALSE, server = TRUE,
                                      options = list(pageLength = nrow(action)))
 
 output$technique <- DT::renderDataTable(technique,
                                         filter = 'top',
                                         rownames = FALSE, server = TRUE,
                                         options = list(pageLength = nrow(technique)))
 
})


