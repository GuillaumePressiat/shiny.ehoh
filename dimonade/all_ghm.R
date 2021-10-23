bind_rows(
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v11g.xlsx', skip = 3), anseqta = 2015) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2016.xlsx', skip = 3), anseqta = 2016) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2017.xlsx', skip = 3), anseqta = 2017) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2018.xlsx', skip = 3), anseqta = 2018) %>% 
  #   rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2019.xlsx', skip = 3), anseqta = 2019) %>% 
    rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2020.xlsx', skip = 3), anseqta = 2020) %>% 
    rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_ghm_v2021.xlsx', skip = 3), anseqta = 2021) %>% 
    rename_all(stringr::str_trim))-> ghm

bind_rows(
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v11g.xlsx', skip = 2, sheet = 'racines_V11g'), anseqta = 2015) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2016.xlsx', skip = 2, sheet = 'racines_V2016'), anseqta = 2016) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2017.xlsx', skip = 2, sheet = 'racines_V2017'), anseqta = 2017) %>% 
  #   rename_all(stringr::str_trim),
  # mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2018.xlsx', skip = 2, sheet = 'racines_V2018'), anseqta = 2018) %>% 
  #   rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2019.xlsx', skip = 2, sheet = 'racines_V2019'), anseqta = 2019) %>% 
    rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2020.xlsx', skip = 2, sheet = 'racines_V2019'), anseqta = 2020) %>% 
    rename_all(stringr::str_trim),
  mutate(readxl::read_excel('sources/ghm/rgp_atih/regroupement_racinesghm_v2021.xlsx', skip = 2, sheet = 'racines_V2019'), anseqta = 2021) %>% 
    rename_all(stringr::str_trim)) -> rghm

library(readr)
readr::cols(
  `GHS-NRO` = col_integer(),
  `CMD-COD` = col_integer(),
  `DCS-MCO` = col_character(),
  `GHM-NRO` = col_character(),
  `GHS-LIB` = col_character(),
  `SEU-BAS` = col_integer(),
  `SEU-HAU` = col_integer(),
  `GHS-PRI` = col_double(),
  `EXB-FORFAIT` = col_double(),
  `EXB-JOURNALIER` = col_double(),
  `EXH-PRI` = col_double(),
  `DATE-EFFET` = col_character()
) -> i

bind_rows(
  # mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2015.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2015),
  # mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2016.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2016),
  # mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2017.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2017),
  # mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2018.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2018),
  mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2019.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2019),
  mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2020.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2020),
  mutate(readr::read_csv2('sources/ghm/tarifs/ghs_pub_2021.csv', locale = locale(encoding ='latin1'), col_types = i), anseqta = 2021)) %>%
  mutate(`N° de GHS` = stringr::str_pad(`GHS-NRO`, pad = "0", side = "left", width = 4)) %>%
  rename(GHM = `GHM-NRO`,
         `Libellé du GHS` = `GHS-LIB`,
         `Borne basse` = `SEU-BAS`,
         `Borne haute` = `SEU-HAU`,
         `Tarif base` = `GHS-PRI`,
         `Forfait EXB` = `EXB-FORFAIT`,
         `Tarif EXB` = `EXB-JOURNALIER`,
         `Tarif EXH` = `EXH-PRI`) %>%
  select(- `CMD-COD`, - `DCS-MCO`, - `GHS-NRO`) %>% 
  select(`N° de GHS`, everything()) -> tarifs

readr::read_delim('sources/ghm/tarifs/Supplements_T2A.csv', delim = ";", col_types = readr::cols(.default = col_character())) -> supplements

supplements[-1,] %>% tidyr::gather(`Supplément`, `Tarif`, - libelle) %>% 
  rename(anseqta = libelle) %>% 
  left_join(tibble::enframe(unlist(supplements[1,])), by = c('Supplément' = 'name')) %>% 
  rename(nom_court = value) -> supp

