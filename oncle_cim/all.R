an="16"


# setup
require(readr)
library(dplyr, warn.conflicts = FALSE)
prep <- function(an) {
  
  
  
  a <- readr::read_delim(paste0("../listes_fg/diags/lib_cim10/20",an,"/LIBCIM10.TXT"),skip=0, delim="|", col_names = c('code','tr','lib_court','lib_long'),
                         col_types = cols(code = 'c', tr = 'c', lib_court='c', lib_long='c'), 
                         locale = locale(encoding = 'latin1'))
  
  write_rds(a,paste0('cim',an,'.Rds'))
  

  write_rds(read_csv2(paste0("../listes_fg/listes_manuel_20",an,'_ghm_vol_2.csv'), col_types = cols(
    liste = col_character(),
    code = col_character(),
    rghm = col_character(),
    var = col_character(),
    libelle = col_character(),
    cmd = col_character()
  ), locale = locale(encoding = "latin1")) %>% filter(var == "diags") %>% 
    mutate(num_liste = substr(liste, 3,nchar(liste)),
           e = libelle,
           diag = code, cmd = stringr::str_extract(cmd, '[0-9]{2}')) %>% 
    
    group_by(diag, liste, e, num_liste, libelle, cmd) %>% 
    summarise(rghm = paste0(rghm, collapse = ", ")) %>% ungroup() %>% arrange(num_liste),
            paste0('listes',an,'.Rds'))
}

# prep(11)
# prep(12)
# prep(13)
# prep(14)
prep(15)
prep(16)
prep(17)
prep(18)
