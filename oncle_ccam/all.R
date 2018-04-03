an="18"


# setup
require(tidyverse)
require(readr)

library(dplyr)

prep <- function(an) {
  
  # haven::read_sas('hierarchie_actes.sas7bdat') %>% 
  #   mutate(H = paste0(niv1, niv2, niv3, niv4)) -> a
  # 
  # h <- a %>% filter(type == 'H') %>% select(niveau, parent = code, libelle, libelle_niv1, libelle_niv2, libelle_niv3, libelle_niv4)
  # 
  # a <- a %>% filter(type == 'A') %>% select(code, parent, libelle)
  # 
  library(dplyr)
  #library(dbplyr)
  library(RPostgreSQL)
  pg = dbDriver("PostgreSQL")
  
  con = dbConnect(pg, 
                  user="-----",
                  #host = '------', 
                  #host = 'localhost', 
                  port = -,
                  password="----", dbname="-----")
  
  
  h <- tbl(con, 'ccam_hierarchie_actes') %>% filter(type == 'H') %>% select(-type) %>% collect()
  a <- tbl(con, 'ccam_hierarchie_actes')  %>% filter(type == 'A') %>% collect()
  
  write_rds(a,paste0('ccam',an,'.Rds'))
  write_rds(h,paste0('hierarchie',an,'.Rds'))
  
  # write_rds(arrange(read_tsv(paste0("../listes_fg/actes/resu_ok_20",an,'.txt'), col_types = cols(
  #   acte = col_character(),
  #   phase = col_character(),
  #   attribut = col_character(),
  #   a = col_character(),
  #   b = col_character(),
  #   d = col_character(),
  #   num_liste = col_character(),
  #   rghm = col_character(),
  #   cmd = col_character()
  # )), num_liste) %>% inner_join(a %>% select(code, libelle), by = c('acte' = 'code')),
  #           paste0('listes',an,'.Rds'))
  
  write_rds(read_csv2(paste0("../listes_fg/listes_manuel_20",an,'_ghm_vol_2.csv'), col_types = cols(
    liste = col_character(),
    code = col_character(),
    rghm = col_character(),
    var = col_character(),
    libelle = col_character(),
    cmd = col_character()
  ), locale = locale(encoding = "latin1")) %>% filter(var == "actes") %>% 
    mutate(num_liste = substr(liste, 3,nchar(liste)),
           d = libelle,
           acte = code, cmd = stringr::str_extract(cmd, '[0-9]{2}')) %>% select(-libelle) %>% arrange(num_liste) %>% 
    inner_join(a %>% select(code, libelle), by = c('acte' = 'code')) %>% 
    group_by(acte, liste, d, num_liste, libelle, cmd) %>% 
    summarise(rghm = paste0(rghm, collapse = ", ")) %>% ungroup() %>% arrange(num_liste),
  paste0('listes',an,'.Rds'))
}

prep(15)
prep(16)
prep(17)
prep(18)
