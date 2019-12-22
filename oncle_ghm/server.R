library(shiny)
library(dplyr)
library(stringr)
library(DT)
library(clipr)
library(readr)
# 
# bind_rows(
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_ghm_v11g.xlsx', skip = 3), anseqta = 2015),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_ghm_v2016.xlsx', skip = 3), anseqta = 2016),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_ghm_v2017.xlsx', skip = 3), anseqta = 2017),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_ghm_v2018.xlsx', skip = 3), anseqta = 2018)) -> ghm
# 
# bind_rows(
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_racinesghm_v11g.xlsx', skip = 2, sheet = 'racines_V11g'), anseqta = 2015),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_racinesghm_v2016.xlsx', skip = 2, sheet = 'racines_V2016'), anseqta = 2016),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_racinesghm_v2017.xlsx', skip = 2, sheet = 'racines_V2017'), anseqta = 2017),
#   mutate(readxl::read_excel('sources/rgp_atih/regroupement_racinesghm_v2018.xlsx', skip = 2, sheet = 'racines_V2018'), anseqta = 2018)) -> rghm
# 
# readr::cols(
#   `GHS-NRO` = col_character(),
#   `CMD-COD` = col_integer(),
#   `DCS-MCO` = col_character(),
#   `GHM-NRO` = col_character(),
#   `GHS-LIB` = col_character(),
#   `SEU-BAS` = col_integer(),
#   `SEU-HAU` = col_integer(),
#   `GHS-PRI` = col_double(),
#   `EXB-FORFAIT` = col_double(),
#   `EXB-JOURNALIER` = col_double(),
#   `EXH-PRI` = col_double(),
#   `DATE-EFFET` = col_character()
# ) -> i
# 
# bind_rows(
#   mutate(readr::read_csv2('sources/tarifs/ghs_pub_2015.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2015),
#   mutate(readr::read_csv2('sources/tarifs/ghs_pub_2016.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2016),
#   distinct(mutate(readr::read_csv2('sources/tarifs/ghs_pub_2017.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2017)),
#   distinct(mutate(readr::read_csv2('sources/tarifs/ghs_pub_2018.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2018))) %>%
#   mutate(`N° de GHS` = stringr::str_pad(`GHS-NRO`, pad = "0", side = "left", width = 4)) %>%
#          rename(GHM = `GHM-NRO`,
#          `Libellé du GHS` = `GHS-LIB`,
#          `Borne basse` = `SEU-BAS`,
#          `Borne haute` = `SEU-HAU`,
#          `Tarif base` = `GHS-PRI`,
#          `Forfait EXB` = `EXB-FORFAIT`,
#          `Tarif EXB` = `EXB-JOURNALIER`,
#          `Tarif EXH` = `EXH-PRI`) %>%
#   select(- `CMD-COD`, - `DCS-MCO`, - `GHS-NRO`) %>% 
#   select(`N° de GHS`, everything()) -> tarifs
# 
# # readr::read_delim('sources/tarifs/Supplements_T2A.csv', delim = ",", col_types = readr::cols(.default = col_double())) -> supplements
# # 
# # supplements %>% tidyr::gather(`Supplément`, `Tarif`, `Coeff géo.`:`Supplément défibrillateur cardiaque (SDC)`) -> supp
# 
# readr::read_delim('sources/tarifs/Supplements_T2A.csv', delim = ",", col_types = readr::cols(.default = col_character()), skip = 1) -> supplements
# readr::read_delim('sources/tarifs/Supplements_T2A.csv', delim = ",", col_types = readr::cols(.default = col_character()), skip = - 1, n_max = 2) -> supplementsn
# 
# t(supplementsn) %>% as_data_frame() -> suppn
# 
# # u <- bind_rows(supplements, supplementsn)
# 
# supplements %>% tidyr::gather(Supplement, tarif,  cgeo: sdc) %>% 
#   left_join(suppn, by = c('Supplement' = 'V2')) %>% 
#   rename(anseqta = nom_court,
#          `Libellé` = V1) -> supp

source('all.R')

shinyServer(
  function(input, output) {
  
  df1 <- reactive({
    ghm  %>% filter(anseqta == 2000 + as.numeric(input$an))
  })

  df2 <- reactive({
    rghm %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  
  df3 <- reactive({
    tarifs %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  df4 <- reactive({
    supp %>% filter(anseqta == 2000 + as.numeric(input$an))
  })
  output$dflib1 <- DT::renderDataTable(datatable(
    df1(), extensions = 'Buttons',options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')
    ), rownames = F
  ), server = F)
  
  output$dflib2 <- DT::renderDataTable(datatable(
    df2(), extensions = 'Buttons', options = list(
      dom = 'Bfrtip', searchHighlight = TRUE,
      buttons = c('copy', 'csv', 'excel', 'colvis')), rownames = F), server = F)
  
   output$dflib3 <- DT::renderDataTable(datatable(
     df3(), extensions = 'Buttons', options = list(
       dom = 'Bfrtip', searchHighlight = TRUE,
       buttons = c('copy', 'csv', 'excel', 'colvis')
     ), rownames = F), server = F)
   
   output$dflib4 <- DT::renderDataTable(datatable(
     df4(), extensions = 'Buttons', options = list(
       dom = 'Bfrtip', searchHighlight = TRUE,
       buttons = c('copy', 'csv', 'excel', 'colvis')
     ), rownames = F), server = F)
   
   output$lib <- renderText({
     ghm %>% filter(anseqta == 2000 + as.numeric(input$an), GHM == input$GHM) %>% .$`Libellé`
   })
   
   output$lib <- renderText({
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
})


