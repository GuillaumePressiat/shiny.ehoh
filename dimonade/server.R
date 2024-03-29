library(shiny)
library(dplyr)
library(stringr)
library(DT)
#library(clipr)
library(readr)
library(esquisse)
#library(rclipboard)
library(zeroclipr)
library(rmarkdown)

enrobeur <- function(a, robe = "\'", colonne = F, interstice = ", ", symetrique = F){
  strReverse <- function(x) sapply(lapply(strsplit(x, NULL), rev), paste,
                                   collapse="")
  
  b <- paste0(robe,a,ifelse(symetrique == F,robe, strReverse(robe)))
  if (colonne == F){
    return(paste0(b, collapse = interstice))
  }
  else { return(b)}
  
}
read_rds('sources/ccam/ccam.Rds') -> ccam

read_rds('sources/ccam/ccam_hierarchie.Rds') -> ccam_hierarchie

read_rds('sources/ccam/ccam_notes.Rds') -> ccam_notes

read_rds('sources/ccam/ccam_listes_20.Rds') -> ccam_listes_20
read_rds('sources/ccam/ccam_listes_19.Rds') -> ccam_listes_19
read_rds('sources/ccam/ccam_listes_18.Rds') -> ccam_listes_18
read_rds('sources/ccam/ccam_listes_17.Rds') -> ccam_listes_17
read_rds('sources/ccam/ccam_listes_16.Rds') -> ccam_listes_16
read_rds('sources/ccam/ccam_listes_15.Rds') -> ccam_listes_15

readr::read_rds('sources/ccam/topographie.Rds') %>%  dplyr::select( Code = Code2, `Code Site Ana.` = Code, dplyr::everything()) -> topographie
readr::read_rds('sources/ccam/action.Rds') -> action
readr::read_rds('sources/ccam/technique.Rds') -> technique

read_rds('sources/cim/cim_15.Rds') -> cim_15
read_rds('sources/cim/cim_16.Rds') -> cim_16
read_rds('sources/cim/cim_17.Rds') -> cim_17
read_rds('sources/cim/cim_18.Rds') -> cim_18
read_rds('sources/cim/cim_19.Rds') -> cim_19
read_rds('sources/cim/cim_20.Rds') -> cim_20

read_rds('sources/cim/cim_listes_15.Rds') -> cim_listes_15
read_rds('sources/cim/cim_listes_16.Rds') -> cim_listes_16
read_rds('sources/cim/cim_listes_17.Rds') -> cim_listes_17
read_rds('sources/cim/cim_listes_18.Rds') -> cim_listes_18
read_rds('sources/cim/cim_listes_19.Rds') -> cim_listes_19
read_rds('sources/cim/cim_listes_20.Rds') -> cim_listes_20

source("all_ghm.R")
#source("all_guiliste.R")
library(esquisse)

lccam <- ccam %>% distinct(codes = substr(code,1,4)) %>% pull(codes)

poss <-c("0 Pas de restriction",
         "1 Interdit en DP et en DR, autorisé ailleurs",
         "2 Interdit en DP et en DR, cause externe de morbidité", 
         "3 interdit en DP, DR, DA", 
         "4 Interdit en DP, autorisé ailleurs")

shinyServer(function(input, output, session){
  
  
  output$value <- renderPrint({
    dataset <- datasetInput()
    cat(as.character(dataset$code), sep = ', ')
  })
  
  # voir la table
  output$ccam_df2 <- DT::renderDataTable(distinct(get('ccam') %>% 
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
  #niveau_hiera_ccam
  ccam_hiera_explore <- reactive({
    get('ccam_hierarchie') %>% 
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
        `Niveau hiérarchique` == 4 ~ '4 - Sous-paragraphe'))) %>% 
      filter(`Niveau hiérarchique` %in% input$niveau_hiera_ccam)
  })
  
  output$ccam_df1 <- DT::renderDataTable(ccam_hiera_explore(),
                                    filter = 'top',
                                    options = list(searchHighlight = TRUE, pageLength = 20),
                                    rownames = FALSE, server = TRUE)
  
  output$ccam_df3 <- DT::renderDataTable(distinct(get('ccam_notes') %>% 
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
  output$ccam_listes <- DT::renderDataTable(distinct(select(get(paste0('ccam_listes_',input$an)),`N° de liste` = num_liste, 
                                                       `Nom de la liste` = d, `Racines ghm` = rghm, `CM (D)` = cmd )), 
                                       server = TRUE,
                                       filter = 'top',
                                       rownames = FALSE,
                                       options = list(
                                         searchHighlight = TRUE, 
                                         pageLength = 20,
                                         autoWidth = F))
  
  # Diags des listes 
  ccam_clistet <- reactive({
    get(paste0('ccam_listes_',input$an)) %>% filter(num_liste == input$ccam_num) %>% 
      distinct(acte, .keep_all = T) %>% mutate(acte = str_trim(acte))
  })
  
  
  output$ccam_nliste <- renderPrint({
    dataset <- ccam_clistet()
    cat(unique(paste0(dataset$num_liste,' - ', dataset$d)))
  })
  
  output$ccam_cliste <- renderPrint({
    dataset <- ccam_clistet()
    cat(as.character(unique(dataset$acte)), sep = ', ')
  })
  
  observeEvent(input$ccam_copyButton2b, {
    dataset <- ccam_clistet()
    clipr::write_clip(toString(unique(dataset$acte)))
  })
  
  output$ll2 <- reactive({
    ll <- input$listi
    as.character(str_replace_all(ll, "\\,\\s", "\r\n"))
  })

  ccam_clistetlib <- reactive({
    get(paste0('ccam_listes_',input$an)) %>% filter(num_liste == input$ccam_num) %>%
      distinct(acte,  acte_descr, libelle, d, rghm, cmd, date_debut, date_fin) %>% 
      select(`Acte CCAM` = acte, `Acte ATIH` = acte_descr, libelle, nom_liste = d, rghm, cmd, date_debut, date_fin)
  })
  
  output$ccam_dflib <- DT::renderDataTable(datatable(
    ccam_clistetlib(), extensions = 'Buttons', options = list(
      pageLength = nrow(ccam_clistetlib()),
      dom = 'Bfrtip',
      buttons = c('copy' , 'print')
    ), rownames = F
  ),server = F)
  
  appartient_ccam <- reactive({
    get(paste0('ccam_listes_',input$an)) %>% filter(acte == input$ccam_listi) %>% 
      distinct(num_liste, .keep_all = T) %>% select(Acte = acte, 
                                                    `Acte ATIH` = acte_descr,
                                                    `Nom de la liste`= d, `N° liste` = num_liste, `CM (D)` = cmd, `Racines ghm` = rghm)
  })
  
  output$datappartient_ccam <- DT::renderDataTable(datatable(appartient_ccam(), options = list(
    pageLength = nrow(appartient_ccam()))))
  
  output$clip <- renderUI({
    
    str <- textConnection("te", open = "w")
    write.table(paste0(as.character(ccam_clistet()$acte), collapse = ", "), str, 
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
  
  observeEvent(input$cim_copyButton1a, {
    clipr::write_clip(as.character(dataset$code))
    observeEvent(input$copyButton1b, {
      clipr::write_clip(paste0(as.character(dataset$code), collapse = ", "))
    })
    observeEvent(input$copyButton1c, {
      clipr::write_clip(print(dataset$code))
    })
  })
  
  output$cim_df <- DT::renderDataTable(get(paste0('cim_',input$an)) %>% 
                                     select(Code = code, `Type de restriction MCO/HAD` = tr,
                                            # `Type SSR` = tssr,
                                            # `Type Psy` = tpsy,
                                            `Libellé` = lib_long),
                                   filter = 'top',
                                   options = list(searchHighlight = TRUE, regex = TRUE, pageLength = 20),
                                   rownames = FALSE, server = TRUE)
  
  
  hiera <- reactive({
    
    if (input$regexp_cim == TRUE){

        tete <- get(paste0('cim_',input$an)) %>%
          distinct(chapitre, chapitre_regexp, lib_chapitre,
                   bloc, bloc_regexp, lib_bloc,
                   categorie, lib_categorie)
    } else {
        tete <- get(paste0('cim_',input$an)) %>% 
          distinct(chapitre, lib_chapitre, 
                   bloc, lib_bloc,
                   categorie, lib_categorie)
     }
    
    if (input$niveau_hiera == 'Catégorie'){
      return(tete %>% select(categorie, lib_categorie, bloc, lib_bloc, everything()))
    }
    if (input$niveau_hiera == 'Bloc'){
      if (input$regexp_cim){return(tete %>% distinct(bloc, lib_bloc, chapitre, lib_chapitre, bloc_regexp))}
      return(tete %>% distinct(bloc, lib_bloc, chapitre, lib_chapitre))
    }
    if (input$niveau_hiera == 'Chapitre'){
      if (input$regexp_cim){return(tete %>% distinct(chapitre, lib_chapitre, chapitre_regexp))}
      return(tete %>% distinct(chapitre, lib_chapitre))
    }
    }
  )

  output$cim_hiera_df <- DT::renderDataTable(hiera(),
                        filter = 'top',
                        options = list(searchHighlight = TRUE, regex = TRUE, pageLength = 25),
                        rownames = FALSE, server = TRUE)
    
  
  output$cim_liste <- DT::renderDataTable(distinct(select(get(paste0('cim_listes_',input$an)), `N° de la liste` = num_liste, 
                                                      `Nom de la liste` = e,
                                                      `Racines ghm` = rghm,
                                                      CMD = cmd)), server = TRUE,
                                      filter = 'top',
                                      rownames = FALSE,
                                      options = list(searchHighlight = TRUE, pageLength = 20))
  
  cim_clistet <- reactive({
    if (!grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% filter(num_liste == input$cim_num) %>% 
        distinct(diag) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', ''))
    }
    else if (grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% filter(paste0('CMD',substr(num_liste,1,2)) == input$cim_num, nchar(num_liste) == 4) %>% 
        distinct(diag) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', ''))
    }
  })
  
  cim_clistetot <- reactive({
    if (!grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% filter(num_liste == input$cim_num)}
    else if (grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% 
        filter(paste0('CMD',substr(num_liste,1,2)) == input$cim_num, nchar(num_liste) == 4)
    }
  })
  
  output$cim_cliste <- renderPrint({
    dataset <- cim_clistet()
    cat(as.character(dataset$diag), sep = ', ')
  })
  
  cim_clistetlib <- reactive({
    if (!grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% filter(num_liste == input$cim_num) %>% rename(nom_liste = e) %>% 
        distinct(diag, num_liste, nom_liste, rghm, cmd) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>%
        inner_join( get(paste0('cim_',input$an)) %>%
                      mutate(code = str_trim(code)) %>%
                      select(code, lib_long), by = c("diag"="code"))
    }
    
    else if (grepl('CMD', input$cim_num)){
      get(paste0('cim_listes_',input$an)) %>% 
        filter(paste0('CMD',substr(num_liste,1,2)) == input$cim_num, nchar(num_liste) == 4) %>% rename(nom_liste = e) %>% 
        distinct(diag, num_liste, nom_liste, rghm, cmd) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>%
        inner_join( get(paste0('cim_',input$an)) %>%
                      mutate(code = str_trim(code)) %>%
                      select(code, lib_long), by = c("diag"="code"))
    }
    
  })
  
  cim_appartient <- reactive({
    get(paste0('cim_listes_',input$an)) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>% 
      filter(diag == input$cim_listi) %>% 
      distinct(num_liste, .keep_all = T) %>% select(Diag = diag, `Nom de la liste`= e, `N° liste` = num_liste, `Racines ghm` = rghm, `Cmd` = cmd)
  })
  
  output$datappartient_cim <- DT::renderDataTable(datatable(cim_appartient(), options = list(
    pageLength = nrow(cim_appartient()))))
  
  output$cim_clip <- renderUI({

    str <- textConnection("te", open = "w")
    write.table(paste0(as.character(cim_clistet()$diag), collapse = ", "), str,
                quote = F, row.names = FALSE, col.names = F)
    close(str)
    zeroclipButton("cim_clipbtn", "Copie Liste", te, icon("clipboard"))


  })
  output$cim_dflib <- DT::renderDataTable(datatable(
    cim_clistetlib(), extensions = 'Buttons', options = list(
      pageLength = nrow(cim_clistetlib()),
      dom = 'Bfrtip',
      buttons = c('copy' , 'print')
    ), rownames = F
  ),server = F)
  
  
  
  ghm_df1 <- reactive({
    ghm  %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  
  ghm_df2 <- reactive({
    rghm %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  
  ghm_df3 <- reactive({
    tarifs %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  ghm_df4 <- reactive({
    supp %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  
  output$ghm_dflib1 <- DT::renderDataTable(datatable(
    ghm_df1(), extensions = 'Buttons',options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')
    ), rownames = F
  ), server = F)
  
  output$ghm_dflib2 <- DT::renderDataTable(datatable(
    ghm_df2(), extensions = 'Buttons', options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')), rownames = F), server = F)
  
  output$ghm_dflib3 <- DT::renderDataTable(datatable(
    ghm_df3(), extensions = 'Buttons', options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')
    ), rownames = F), server = F)
  
  output$ghm_dflib4 <- DT::renderDataTable(datatable(
    ghm_df4(), extensions = 'Buttons', options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')
    ), rownames = F), server = F)
  
  output$ghm_lib <- renderText({
    ghm %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>% .$`Libellé`
  })
  
  output$da <- renderText({
    ghm %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>% 
      mutate(DA = paste0(DA, " - ", ASO,  ' - ',`libellé domaine d'activité`)) %>%
      .$DA
  })
  output$racine <- renderText({
    rghm %>% filter(anseqta == 2000 + as.numeric(input$an), racine == substr(input$GHM,1,5)) %>% 
      mutate(rghm1 = paste0(racine, " - ", libelle)) %>%
      .$rghm1
  })
  output$gp <- renderText({
    ghm %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>% 
      mutate(GP = paste0(`GP_CAS`, " - ", `libellé groupes de type planification`)) %>%
      .$GP
    
  })
  output$ga <- renderText({
    ghm %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>% 
      mutate(GA = paste0(GA, " - ", `libellé Groupes d'Activité`)) %>%
      .$GA
    
  })
  t <- reactive({
    as.data.frame(
      tarifs %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>%
        select(-GHM, - `Libellé du GHS`))})
  output$tarifs <- DT::renderDataTable(datatable(t()
                                                 , rownames = F,  options = list(dom = 't', searchHighlight = TRUE)), server = F)
  
  
  outVar <- reactive({
    
    if (input$text == ''){return('')}
    
    if (input$nomenclature == "CIM"){
      #vars <- all.vars(parse(text = input$text))
      vars <- lcim()[grepl(paste0("^(", paste0(toupper(input$text) %>% stringr::str_split(', ') %>% unlist(), 
                                             collapse = "|"), ")"), lcim())]
    } else if (input$nomenclature == "CCAM"){
      vars <- lccam[grepl(paste0("^(", paste0(toupper(input$text) %>% stringr::str_split(', ') %>% unlist(), 
                                              collapse = "|"), ")"), lccam)]
    }
    vars <- as.list(vars)
    return(vars)
  })
  
  output$var2 <- renderUI({
    
    dragulaInput('dragula_input2',
                 
                 badge = TRUE,
                 # choices = c('C00', 'C01'),
                 choices = outVar(),
                 targetsIds = 'target',
                 height = 150,
                 targetsLabels = 'Déposer',
                 sourceLabel = 'Glisser', width = "100%")})
  
  
  #output$result <- renderPrint(str(input$dragula_input))
  
  observeEvent(input$nomenclature, {
    if (input$nomenclature == "CIM"){
      shinyjs::show('positions')
    } else if (input$nomenclature == "CCAM"){
      shinyjs::hide('positions')
    } 
  })
  
  cim <- reactive({get(paste0("cim_", input$an))})
  lcim <- reactive({cim() %>% distinct(cats = substr(code,1,3)) %>% pull(cats)})
  
  
  output$liste <- renderText({
    #if (input$text == ''){return(NULL)}
    if (input$nomenclature == "CIM"){
      if (!is.null(input$dragula_input2$target$target)){
        d <- cim() %>% filter(substr(code,1,3) %in% (input$dragula_input2$target %>% unlist()),
                              tr %in% input$positions) %>% 
          distinct(code) %>% 
          pull(code)
      } else {
        d <- cim() %>% filter(substr(code,1,3) %in% (input$dragula_input2$source %>% unlist()),
                              tr %in% input$positions) %>% 
          distinct(code) %>% 
          pull(code)
        
      }

      if (input$code_pere){
        d <- substr(d,1,3) %>% unique()
      }
      
    } 
    
    if (input$nomenclature == "CCAM"){
      if (!is.null(input$dragula_input2$target$target)){
        d <- ccam %>% filter(substr(code, 1,4) %in% (input$dragula_input2$target %>% unlist())) %>% 
          distinct(code = substr(code,1,7)) %>% pull(code)
      } else {
        d <- ccam %>% filter(substr(code, 1,4) %in% (input$dragula_input2$source %>% unlist())) %>% 
          distinct(code = substr(code,1,7)) %>% pull(code)
        
      }

      if (input$code_pere){
        d <- substr(d, 1, 4) %>% unique()
      }

    }
    if (input$format_liste == 'nu'){
      return(stringr::str_wrap(d %>% paste0(collapse = input$sep_l), width = input$wrapw))
    } else
      if (input$format_liste == 'simple quote'){
        return(stringr::str_wrap(enrobeur(d, robe = "'", colonne = F, interstice = input$sep_l), width = input$wrapw))
      } else
        if (input$format_liste == 'double quote'){
          return(stringr::str_wrap(enrobeur(d, robe = "\"", colonne = F, interstice = input$sep_l), width = input$wrapw))
        } else
          if (input$format_liste == 'pipe'){
            return(enrobeur(d, robe = "", colonne = F, interstice = "|"))
          } else
            if (input$format_liste == 'SQL like%'){
              return(stringr::str_wrap(paste0(input$sep_l, enrobeur(paste0(d, "%"), robe = "'", colonne = F, interstice = input$sep_l)), width = input$wrapw))
            }
  })
  #output$liste <- renderText(liste_texte())
  observeEvent(input$format_liste,{
    if (! input$format_liste %in% c("pipe", 'SQL like%')){
      updateTextInput(session, inputId = 'sep_l', value = ", ")
    }
    if (input$format_liste == "pipe"){
      updateTextInput(session, inputId = 'sep_l', value = '|')
    } else if (input$format_liste == "SQL like%"){
      updateTextInput(session, 
                      inputId = 'sep_l', 
                      value = ' or code like ')
    }
  })
  

  
  observeEvent(input$wrapof,{
    if (input$wrapof){
      shinyjs::show('wrapw')
      updateNumericInput(session, 'wrapw', value = 80)
    } else {
      updateNumericInput(session, 'wrapw', value = 1e6)  
      shinyjs::hide('wrapw')
      }
    })
  
  observeEvent(input$nomenclature,{
    if (input$nomenclature == "CIM"){
      updateTextInput(session, inputId = 'text', placeholder = 'H[6-9], e4')
      #updateNumericInput(session, inputId = 'nb_chara', value = 6, max = 6, min = 3)
      shinyWidgets::updateSwitchInput(session, inputId = 'code_pere', onLabel = "Catégories", offLabel = "Codes CIM")
    } else if (input$nomenclature == "CCAM"){
      updateTextInput(session, 
                      inputId = 'text', 
                      value = '', placeholder = 'N.KA, EB, ZZLP')
      #updateNumericInput(session, inputId = 'nb_chara', value = 7, max = 7, min = 1)
      shinyWidgets::updateSwitchInput(session, inputId = 'code_pere', onLabel = "Codes pères", offLabel = "Codes CCAM")
    }
  })
  
  output$sourceliste <- renderText({
    paste0(unlist(input$source), collapse = ", ")
  })
  
  diags1 <-  reactive({
    if (input$text == ''){return(NULL)}
    if (input$nomenclature == "CIM"){
      if (!is.null(input$dragula_input2$target$target)){
        i <- cim() %>% filter(substr(code, 1,3) %in% (input$dragula_input2$target %>% unlist()),
                               tr %in% input$positions) %>% 
          distinct(code, tr, lib_long, bloc, lib_bloc, chapitre, lib_chapitre)
      } else {
        i <- cim() %>% filter(substr(code, 1,3) %in% (input$dragula_input2$source %>% unlist()),
                               tr %in% input$positions) %>% 
          distinct(code, tr, lib_long, bloc, lib_bloc, chapitre, lib_chapitre)
        
      }} else if (input$nomenclature == "CCAM"){
        if (!is.null(input$dragula_input2$target$target)){
          i <- ccam %>% filter(substr(code, 1,4) %in% (input$dragula_input2$target %>% unlist())) %>% 
            distinct(code, libelle, strate)  
        } else {
          i <- ccam %>% filter(substr(code, 1,4) %in% (input$dragula_input2$source %>% unlist())) %>% 
            distinct(code, libelle, strate)
        }
      }
    i
  })
  
  output$diags2 <- DT::renderDataTable(datatable(
    diags1(), extensions = 'Buttons', options = list(
      dom = 'Bfrtip', searchHighlight = TRUE, pageLength = min(nrow(diags1()), 100L),
      buttons = c('copy', 'csv', 'excel')), rownames = F), server = F)
  
  observeEvent(input$nomenclature, {
    if (input$nomenclature == "CIM") {
      updateDragulaInput(
        session = session, 
        inputId = "dragula_input2", 
        choices = outVar()
      )
    } else if (input$nomenclature == "CCAM") {
      updateDragulaInput(
        session = session, 
        inputId = "dragula_input2", 
        choices = outVar()
      )
    }
  }, ignoreInit = TRUE)
  
})



