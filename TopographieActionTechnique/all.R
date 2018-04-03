library(magrittr)

# import xlsx export rds

readxl::read_excel('DicoCodeCCAM.xlsx', sheet = 'Topographie') -> topographie
readxl::read_excel('DicoCodeCCAM.xlsx', sheet = 'Action') %>% dplyr::select(-`Libellé de l'action`) -> action
readxl::read_excel('DicoCodeCCAM.xlsx', sheet = 'Technique') %>% dplyr::select(-`Libellé du mode d'accès`)-> technique


saveRDS(topographie, 'topographie.Rds')
saveRDS(action, 'action.Rds')
saveRDS(technique, 'technique.Rds')
