


lccam <- ccam %>% distinct(codes = substr(code,1,4)) %>% pull(codes)

poss <-c("0 Pas de restriction",
         "1 Interdit en DP et en DR, autorisé ailleurs",
         "2 Interdit en DP et en DR, cause externe de morbidité", 
         "3 interdit en DP, DR, DA", 
         "4 Interdit en DP, autorisé ailleurs")
