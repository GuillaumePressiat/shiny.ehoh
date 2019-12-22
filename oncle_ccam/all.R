# an="19"
# 
# 
# # setup
# require(tidyverse)
# require(readr)
# 
# library(dplyr)
# 
# prep <- function(an) {
# 
#   # haven::read_sas('hierarchie_actes.sas7bdat') %>%
#   #   mutate(H = paste0(niv1, niv2, niv3, niv4)) -> a
#   #
#   # h <- a %>% filter(type == 'H') %>% select(niveau, parent = code, libelle, libelle_niv1, libelle_niv2, libelle_niv3, libelle_niv4)
#   #
#   # a <- a %>% filter(type == 'A') %>% select(code, parent, libelle)
#   #
#   library(dplyr)
#   #library(dbplyr)
# #  library(RPostgreSQL)
#   #pg = dbDriver("PostgreSQL")
# 
#   # con = dbConnect(pg,
#   #                 user="-----",
#   #                 #host = '------',
#   #                 #host = 'localhost',
#   #                 port = -,
#   #                 password="----", dbname="-----")
#   #
#   con <- DBI::dbConnect(RSQLite::SQLite(), "~/Documents/R/PG/pg.sqlite")
# 
#   h <- tbl(con, 'ccam_hierarchie_actes') %>% filter(type == 'H') %>% select(-type) %>% collect() %>% 
#     mutate_at(vars(starts_with('niveau_')), stringr::str_pad, width = 2, side = "left", pad = "0") %>% 
#     tidyr::unite(strate, niveau_1,niveau_2,niveau_3,niveau_4, sep = ".")
#   
#   a <- tbl(con, 'ccam_actes_avec_descri') %>%
#     select(code, libelle_long, extension_descriptive, flag_descri, date_debut, date_fin) %>%
#     inner_join(tbl(con, 'ccam_hierarchie_actes') %>% filter(type == 'A') %>% select(code, parent)) %>%
#     collect() %>%
#     mutate(code = case_when(
#       is.na(extension_descriptive) & is.na(flag_descri) ~ code,
#       is.na(extension_descriptive) & !is.na(flag_descri) ~ paste0(code, "-°°"),
#       !is.na(extension_descriptive) ~ paste0(code, "-", extension_descriptive))) %>%
#     select(code, parent, libelle = libelle_long, date_debut, date_fin) %>%
#     left_join(h %>% select(code, strate), by = c('parent' = 'code'))
# 
#   write_rds(a,paste0('ccam',an,'.Rds'))
#   write_rds(h,paste0('hierarchie',an,'.Rds'))
# 
#   write_rds(read_csv2(paste0("../listes_fg/listes_manuel_20",an,'_ghm_vol_2.csv'), col_types = cols(
#     liste = col_character(),
#     code = col_character(),
#     rghm = col_character(),
#     var = col_character(),
#     libelle = col_character(),
#     cmd = col_character()
#   )) %>% filter(var == "actes") %>% #, locale = locale(encoding = "latin1")
#     mutate(num_liste = substr(liste, 3,nchar(liste)),
#            d = libelle,
#            acte = code, cmd = stringr::str_extract(cmd, '[0-9]{2}')) %>% select(-libelle) %>% arrange(num_liste) %>%
#     inner_join(a %>% select(code, acte_descr = code, libelle, date_debut, date_fin) %>% mutate(code = substr(acte_descr, 1, 7)), by = c('acte' = 'code')) %>%
#     group_by(acte, acte_descr, date_debut, date_fin, liste, d, num_liste, libelle, cmd) %>%
#     summarise(rghm = paste0(rghm, collapse = ", ")) %>% ungroup() %>% arrange(num_liste),
#   paste0('listes',an,'.Rds'))
# }
# 
# prep(15)
# prep(16)
# prep(17)
# prep(18)
# prep(19)

