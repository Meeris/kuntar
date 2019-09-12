## ---------------------------
##
## Script name: create_leikkidata
##
## Purpose of script: create two dataset with imaginery data for examples
##
## Author: Meeri Seppa
##
## Date Created: 2019-06-24
##
## Copyright (c) Meeri Seppa, 2019
## Email: meeri.seppa@helsinki.fi
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------



## load the latest version of mapdata
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")



## create a made up statistic for year 1930
data1 <- files %>% 
  pluck(4) %>%
  as_tibble() %>% 
  dplyr::select(nimi, id) %>%
  distinct() %>% 
  mutate(muuttuja = rpois(nrow(.), 100))

## create a made up statistic for year 1970 
data2 <- files %>% 
  pluck(5) %>%
  as_tibble() %>% 
  dplyr::select(nimi, id) %>% 
  distinct() %>%
  mutate(muuttuja = rpois(nrow(.), 100))



## save 
write_csv(data1, "./data/leikkidata_1930.csv")
write_csv(data2, "./data/leikkidata_1970.csv")
