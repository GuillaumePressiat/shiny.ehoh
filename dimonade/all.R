# # an="19"
# x <- "[A15-A19]"
# x <- "[A00-B99]"
# x <- "[B25-B34]"
# regpex_cim <- function(x){
#   liste_lettres <- list('', '')
#   liste_chiffres <- list(0,0,0,0)
#   lettres  <- stringr::str_extract_all(x, '[A-Z]') %>% unlist()
#   chiffres <- stringr::str_extract_all(x, '[0-9]{2}') %>% unlist() %>%
#     stringr::str_extract_all('[0-9]') %>% purrr::map(as.integer)
# 
#   lettreschiffres <- stringr::str_extract_all(x, '[A-Z][0-9]{1}') %>% unlist()
# 
#   if (length(unique(lettreschiffres)) == 1){
#     resu <- paste0(unique(lettreschiffres), '[', chiffres[[1]][2], '-',chiffres[[2]][2], ']')
#     return(resu)
#   }
#   if (length(unique(lettres)) == 1){
#     liste_lettres  <- list(lettres[[1]][1],lettres[[1]][1])
#     liste_chiffres <- list(chiffres[[1]][1], max(0, chiffres[[2]][1] - 1),
#                            chiffres[[1]][2], chiffres[[2]][2])
# 
#     if (identical(chiffres[2] %>% unlist, c(9L,9L)) & identical(chiffres[1] %>% unlist, c(0L,0L))){
#       resu <- paste0(liste_lettres[[1]], '[0-9][0-9]')
#       return(resu)
#     } else if (length(unique(lettreschiffres))> 1){
#       resu <- paste0(liste_lettres[[1]], '[', chiffres[[1]][1], '-', max(0, chiffres[[2]][1] - 1), '][',
#                      chiffres[[1]][2], '-9]',
#                      '|', liste_lettres[[1]], chiffres[[2]][1], '[0-', chiffres[[2]][2], ']')
#       return(resu)
#     } else {
#       resu <- paste0(liste_lettres[[1]], '[', chiffres[[1]][1], '-', max(0, chiffres[[2]][1] - 1), '][0-9]',
#                      '|', liste_lettres[[1]], chiffres[[2]][1], '[0-', chiffres[[2]][2], ']')
# 
# 
#     return(resu)
#     }
#   }
# 
#   if (length(unique(lettres)) > 1){
#     liste_lettres  <- list(lettres[[1]][1],lettres[[2]][1])
#     liste_chiffres <- list(chiffres[[1]][1], max(0, chiffres[[2]][1] - 1),
#                            chiffres[[1]][2], chiffres[[2]][2])
#     if (identical(chiffres[2] %>% unlist, c(9L,9L)) & identical(chiffres[1] %>% unlist, c(0L,0L))){
#       resu <- paste0('[', liste_lettres[[1]], liste_lettres[[2]], ']', '[0-9][0-9]')
#       return(resu)
#     }
#     else{
# 
# 
#     resu <- paste0(liste_lettres[[1]], '[', chiffres[[1]][1], '-', 9, '][0-9]',
#                    '|', liste_lettres[[2]], '[0-', chiffres[[2]][1], '][0-', chiffres[[2]][2], ']')
#   return(resu)
#     }
#   }
# 
# }
# 
# 
# 
# # setup
# require(tidyverse)
# require(readr)
# 
# library(dplyr)
# 
# prep_ccam <- function(an) {
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
#   n <- tbl(con, 'ccam_notes') %>%
#     arrange(code, type_note) %>%
#     collect()
# 
#   write_rds(a,paste0('sources/ccam/ccam','.Rds'))
#   write_rds(h,paste0('sources/ccam/ccam_hierarchie','.Rds'))
#   write_rds(n,paste0('sources/ccam/ccam_notes','.Rds'))
# 
#   write_rds(read_csv2(paste0("../../Github/shiny.ehoh/listes_fg/listes_manuel_20",an,'_ghm_vol_2.csv'), col_types = cols(
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
#   paste0('sources/ccam/ccam_listes_',an,'.Rds'))
# }
# 
# prep_ccam(15)
# prep_ccam(16)
# prep_ccam(17)
# prep_ccam(18)
# prep_ccam(19)
# 
# #
# #
# #
# # # setup
# prep_cim <- function(an) {
# 
# 
# 
#   # a <- readr::read_delim(paste0("../listes_fg/diags/lib_cim10/20",an,"/LIBCIM10.TXT"),skip=0, delim="|", col_names = c('code','tr','lib_court','lib_long'),
#   #                        col_types = cols(code = 'c', tr = 'c', lib_court='c', lib_long='c'),
#   #                        locale = locale(encoding = 'latin1'))
#   #
#   con <- DBI::dbConnect(RSQLite::SQLite(), "~/Documents/R/PG/pg.sqlite")
# 
#   s <- as.character(2000 + an)
#   a <- tbl(con, 'cim_hierarchie_code') %>% filter(time_i == local(s)) %>% collect()
#   chaps <- distinct(a, chapitre) %>%
#     mutate(chapitre_regexp = chapitre %>% purrr::map_chr(regpex_cim)) %>%
#     mutate(chapitre_regexp = stringr::str_replace(chapitre_regexp, '\\[0-0\\]', '0') %>%
#            stringr::str_replace('\\[1-1\\]', '1') %>%
#            stringr::str_replace('\\[2-2\\]', '2') %>%
#            stringr::str_replace('\\[3-3\\]', '3') %>%
#            stringr::str_replace('\\[4-4\\]', '4') %>%
#            stringr::str_replace('\\[5-5\\]', '5') %>%
#            stringr::str_replace('\\[6-6\\]', '6') %>%
#            stringr::str_replace('\\[7-7\\]', '7') %>%
#            stringr::str_replace('\\[8-8\\]', '8') %>%
#            stringr::str_replace('\\[9-9\\]', '9') %>%
#              stringr::str_replace('\\[0-9\\]\\[0-9\\]', '\\[0-9\\]\\{2\\}'))
# 
#   blocs <- distinct(a, bloc) %>%
#     mutate(bloc_regexp = bloc %>% purrr::map_chr(regpex_cim)) %>%
#     mutate(bloc_regexp = stringr::str_replace(bloc_regexp, '\\[0-0\\]', '0') %>%
#              stringr::str_replace('\\[1-1\\]', '1') %>%
#              stringr::str_replace('\\[2-2\\]', '2') %>%
#              stringr::str_replace('\\[3-3\\]', '3') %>%
#              stringr::str_replace('\\[4-4\\]', '4') %>%
#              stringr::str_replace('\\[5-5\\]', '5') %>%
#              stringr::str_replace('\\[6-6\\]', '6') %>%
#              stringr::str_replace('\\[7-7\\]', '7') %>%
#              stringr::str_replace('\\[8-8\\]', '8') %>%
#              stringr::str_replace('\\[9-9\\]', '9') %>%
#     stringr::str_replace('\\[0-9\\]\\[0-9\\]', '\\[0-9\\]\\{2\\}'))
# 
#   a <- a %>% left_join(chaps) %>% left_join(blocs)
#   write_rds(a,paste0('sources/cim/cim_',an,'.Rds'))
# 
# 
#   write_rds(read_csv2(paste0("../../Github/shiny.ehoh/listes_fg/listes_manuel_20",an,'_ghm_vol_2.csv'), col_types = cols(
#     liste = col_character(),
#     code = col_character(),
#     rghm = col_character(),
#     var = col_character(),
#     libelle = col_character(),
#     cmd = col_character()
#   )) %>% filter(var == "diags") %>% #, locale = locale(encoding = "latin1")
#     mutate(num_liste = substr(liste, 3,nchar(liste)),
#            e = libelle,
#            diag = code, cmd = stringr::str_extract(cmd, '[0-9]{2}')) %>%
# 
#     group_by(diag, liste, e, num_liste, libelle, cmd) %>%
#     summarise(rghm = paste0(rghm, collapse = ", ")) %>% ungroup() %>% arrange(num_liste),
#             paste0('sources/cim/cim_listes_',an,'.Rds'))
# }
# 
# 
# prep_cim(15)
# prep_cim(16)
# prep_cim(17)
# prep_cim(18)
# prep_cim(19)



