library(shiny)
library(dplyr)
library(stringr)
library(DT)
library(rmarkdown)
#library(clipr)
library(readr)
#library(rclipboard)
library(zeroclipr)

clipboard <- function(x, sep="\t", row.names=FALSE, col.names=TRUE){
  con <- pipe("xclip -selection clipboard -i", open="w")
  write.table(x, con, sep=sep, row.names=row.names, col.names=col.names)
  close(con)
}

read_rds('cim15.Rds') -> cim15
read_rds('cim16.Rds') -> cim16
read_rds('cim17.Rds') -> cim17
read_rds('cim18.Rds') -> cim18
read_rds('cim19.Rds') -> cim19

read_rds('listes15.Rds') -> listes15
read_rds('listes16.Rds') -> listes16
read_rds('listes17.Rds') -> listes17
read_rds('listes18.Rds') -> listes18
read_rds('listes19.Rds') -> listes19

shinyServer(function(input, output){
  #zeroclipboard_setup()
  
  output$an <- renderPrint({ input$an })
  datasetInput <- reactive({
    get(paste0('cim',input$an)) %>% filter(grepl(input$caption, code), tr != '3')  %>% 
      distinct(code) %>% mutate(code = str_trim(code))
  })
  
  output$value <- renderPrint({
    dataset <- datasetInput()
    cat(as.character(dataset$code), sep = ', ')
    })
  observeEvent(input$copyButton1a, {
    clipr::write_clip(as.character(dataset$code))
    observeEvent(input$copyButton1b, {
      clipr::write_clip(paste0(as.character(dataset$code), collapse = ", "))
    })
    observeEvent(input$copyButton1c, {
      clipr::write_clip(print(dataset$code))
    })
  })
  output$df <- DT::renderDataTable(get(paste0('cim',input$an)) %>% 
                                              select(Code = code, `Type de restriction MCO/HAD` = tr,
                                                     # `Type SSR` = tssr,
                                                     # `Type Psy` = tpsy,
                                                     `Libellé` = lib_long),
                                   filter = 'top',
                                   options = list(searchHighlight = TRUE, regex = TRUE, pageLength = 20),
                                   rownames = FALSE, server = TRUE)
  
  output$liste <- DT::renderDataTable(distinct(select(get(paste0('listes',input$an)), `N° de la liste` = num_liste, 
                                                      `Nom de la liste` = e,
                                                      `Racines ghm` = rghm,
                                                      CMD = cmd)), server = TRUE,
                                      filter = 'top',
                                      rownames = FALSE,
                                      options = list(searchHighlight = TRUE, pageLength = 20))
  
  clistet <- reactive({
    if (!grepl('CMD', input$num)){
    get(paste0('listes',input$an)) %>% filter(num_liste == input$num) %>% 
      distinct(diag) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', ''))
    }
    else if (grepl('CMD', input$num)){
      get(paste0('listes',input$an)) %>% filter(paste0('CMD',substr(num_liste,1,2)) == input$num, nchar(num_liste) == 4) %>% 
        distinct(diag) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', ''))
    }
  })
  
  clistetot <- reactive({
    if (!grepl('CMD', input$num)){
    get(paste0('listes',input$an)) %>% filter(num_liste == input$num)}
    else if (grepl('CMD', input$num)){
      get(paste0('listes',input$an)) %>% 
        filter(paste0('CMD',substr(num_liste,1,2)) == input$num, nchar(num_liste) == 4)
      }
  })
  
  output$cliste <- renderPrint({
    dataset <- clistet()
    cat(as.character(dataset$diag), sep = ', ')
  })

clistetlib <- reactive({
  if (!grepl('CMD', input$num)){
  get(paste0('listes',input$an)) %>% filter(num_liste == input$num) %>% rename(nom_liste = e) %>% 
    distinct(diag, num_liste, nom_liste, rghm, cmd) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>%
    inner_join( get(paste0('cim',input$an)) %>%
                  mutate(code = str_trim(code)) %>%
                  select(code, lib_long), by = c("diag"="code"))
  }
  
  else if (grepl('CMD', input$num)){
    get(paste0('listes',input$an)) %>% 
      filter(paste0('CMD',substr(num_liste,1,2)) == input$num, nchar(num_liste) == 4) %>% rename(nom_liste = e) %>% 
      distinct(diag, num_liste, nom_liste, rghm, cmd) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>%
      inner_join( get(paste0('cim',input$an)) %>%
                    mutate(code = str_trim(code)) %>%
                    select(code, lib_long), by = c("diag"="code"))
  }
  
})

appartient <- reactive({
  get(paste0('listes',input$an)) %>% mutate(diag = str_trim(diag), diag = str_replace(diag, '\\.', '')) %>% 
    filter(diag == input$listi) %>% 
    distinct(num_liste, .keep_all = T) %>% select(Diag = diag, `Nom de la liste`= e, `N° liste` = num_liste, `Racines ghm` = rghm, `Cmd` = cmd)
})

output$datappartient <- DT::renderDataTable(datatable(appartient(), options = list(
  pageLength = nrow(appartient()))))

output$clip <- renderUI({
  
  str <- textConnection("te", open = "w")
  write.table(paste0(as.character(clistet()$diag), collapse = ", "), str, 
              quote = F, row.names = FALSE, col.names = F)
  close(str)
  zeroclipButton("clipbtn", "Copie Liste", te, icon("clipboard"))
})

# 
# output$clip2 <- renderUI({
#   
#   str2 <- textConnection("te2", open = "w")
#   write.table(datasetInput(), str2, quote = F, row.names = FALSE, col.names = F)
#   close(str2)
#   zeroclipButton("clipbtn", "Copie Tab",paste( te2, collapse= "\n"), icon("clipboard"))
# })

# output$clip2 <- renderUI({
#   ll <- as.data.frame(ll = input$listi)
#   ll2 <- str_replace_all(ll$ll, "\\,\\s", "\r\n")
#   str <- textConnection("te", open = "w")
#   write.table(ll2, str, quote = F, row.names = FALSE, col.names = F)
#   close(str)
#   zeroclipButton("clipbtn", "Copie Liste", te, icon("clipboard"))
# })
output$dflib <- DT::renderDataTable(datatable(
  clistetlib(), extensions = 'Buttons', options = list(
    pageLength = nrow(clistetlib()),
    dom = 'Bfrtip',
    buttons = c('copy' , 'print')
  ), rownames = F
),server = F)
})

