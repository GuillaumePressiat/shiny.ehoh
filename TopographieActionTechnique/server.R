


library(shiny)
library(magrittr)
readr::read_rds('topographie.Rds') %>%  dplyr::select( Code = Code2, `Code Site Ana.` = Code, dplyr::everything()) ->topographie
readr::read_rds('action.Rds') -> action
readr::read_rds('technique.Rds') -> technique

shinyServer(function(input, output) {
  
  acte_topo1 <-   reactive({
    unique(topographie[topographie$Code == substr(toupper(input$code),1,2),])
  })
  

  output$acte_topo <-   DT::renderDataTable(DT::datatable(acte_topo1(), extensions = 'Scroller', options = list(scrollY = 40,
                                                                                                 scroller = TRUE,  dom = 't',
                                                                                                 autoWidth = TRUE,
                                                      columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
   DT::formatStyle('Code', backgroundColor = 'cornflowerblue'))
  
  
  acte_acti1 <-   reactive({
    unique(action[action$Code == substr(toupper(input$code),3,3),])
  })
  
  
  output$acte_acti <-   DT::renderDataTable(DT::datatable(acte_acti1(), extensions = 'Scroller', options = list(scrollY = 160,
                                                                                                            scroller = TRUE,  dom = 't',
                                                                                                            autoWidth = TRUE,
                                                                                                            columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
                                              DT::formatStyle('Code', backgroundColor = 'cornflowerblue'))
  
  acte_techn1 <-   reactive({
    unique(technique[technique$Code == substr(toupper(input$code),4,4),])
  })
  
  
  output$acte_techn <-   DT::renderDataTable(DT::datatable(acte_techn1(), extensions = 'Scroller', options = list(scrollY = 160,
                                                                                                            scroller = TRUE,  dom = 't',
                                                                                                            autoWidth = TRUE,
                                                                                                            columnDefs = list(list(width = '50px', targets = c(1))))) %>% 
                                              DT::formatStyle('Code', backgroundColor = 'cornflowerblue'))

  
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
