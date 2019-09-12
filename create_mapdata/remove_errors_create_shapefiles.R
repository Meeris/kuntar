## ---------------------------
##
## Script name: remove_errors
##
## Purpose of script: remove erros from mapfiles
##
## Author: Meeri Seppa
##
## Date Created: 2019-07-31
##
## Copyright (c) Meeri Seppä, 2019
## Email: meeri.seppa@helsinki.fi
##
## ---------------------------
##
## Notes: 
##   
##
## ---------------------------



# load packages, functions and data ---------------------------------------


## packages
library(readr)
library(tidyverse)
library(sf)
library(gridExtra)


## functions
source("./functions/functions_fix_maps.R", encoding = "utf-8")


## mapdata
load("./mapdata/mapfiles_fixed_no_overlaps")

## create maps
map_70 <- files %>% pluck(5)
map_30 <- files %>% pluck(4)
map_10 <- files %>% pluck(3)
map_01 <- files %>% pluck(2)
map_60 <- files %>% pluck(1)


## datasets
changes <- read_csv("./data/kuntamuutokset_1860_1970.csv")
kunnat_lak <- read_csv("./data/lakkautetut_kunnnat_2019_tilastokeskus.csv")
nimenmuutokset <- read_csv("./data/nimenmuutokset.csv")



# merge the datasets ------------------------------------------------------

## manipulate data
kunnat_lak <- kunnat_lak %>% 
  dplyr::select(Nimike, Nimike_1)


## filter the dataset "lakkautetut" and join with dataset "changes"
changes <- kunnat_lak %>%
  dplyr::select(contains("Nimi")) %>%
  mutate(kuntaliitos = "kyllä") %>% 
  left_join(changes, ., by = c("nimi" = "Nimike_1",  "nimi_liitetty_kunta" = "Nimike"))


## filter the dataset "nimenmuutokset" and join with dataset "changes"
changes <- nimenmuutokset %>% 
  dplyr::select(contains("nimi")) %>%
  mutate(nimimuutos = "kyllä") %>%
  left_join(changes, ., by = c("nimi" = "uusi_nimi", "nimi_liitetty_kunta" = "vanha_nimi"))



# examine the potential errors --------------------------------------------
# 
#     UNCOMMENT TO EXPLORE THE ERRORS
#
# ## select time period
# time_period <- changes$aika %>% unique()
# 
# ## start from most recent and go through each time period
# j <- 4
# j <- i - 1
# temp <- changes %>% filter(aika == time_period[j])
# 
# 
# ## examine only municipality merges that do not have a match in either of the 
# ## datasets kunnat_lak or nimenmuutokset
# 
# temp <- temp %>% 
#   filter(nimi != nimi_liitetty_kunta) %>%
#   filter(kerroin > 0.9, is.na(kuntaliitos), is.na(nimimuutos))
#          
# ## go through each observation
# i <- 1
# i <- i + 1
# 
# ## select names on the ith row of dataset "temp"
# names <- temp %>% 
#   dplyr::select(nimi_liitetty_kunta, nimi) %>% 
#   slice(i) %>% 
#   unlist(.)
# names
# 
# ## compare
# compare_maps(files[[j]], files[[j + 1]] , names)
# plot_neighbors(files[[j]], names[i])


# correct the errors 1970 ------------------------------------------------------

## Sääksmäki ja Valkeakoski väärinpäin 70
plot_neighbors(map_70, "Sääksmäki")
map_70 %>% filter(nimi %in% c("Sääksmäki", "Valkeakoski"))
map_70 <- rename_rows(map_70, 455, "Valkeakoski", "290")
map_70 <- rename_rows(map_70, 456, "Sääksmäki", "551")


## Pyhämaa 

  ## divide the polygon
  pyhamaa <- map_70 %>% filter(rowid %in% 371)
  map_70 <- map_70 %>% filter(nimi != "Pyhämaa")
  map_70 <- rbind(map_70, st_cast(pyhamaa, "POLYGON")) 
  
  ## new rowids
  rowid_max <- map_70 %>% pull(rowid) %>% max()
  map_70$rowid[map_70$nimi %in% "Pyhämaa"] <- lead(rowid_max : c(rowid_max + 4), default = NULL)
  
  ## 3/4 pyhamaa -> Uusikaupunki
  map_70$nimi[map_70$rowid %in% c(522, 521, 519)] <- "Uusikaupunki" 
  map_70$id[map_70$rowid %in% c(522, 521, 519)] <- "287" 


# correct the errors 1930 -------------------------------------------------


## Kullaa ja ulvila väärinpäin 30 
map_70 %>% filter(nimi %in% c("Kullaa", "Ulvila"))
map_30 <- rename_rows(map_30, 379, "Kullaa", "411")
map_30 <- rename_rows(map_30, 380, "Ulvila", "281")


## Yli-iin kirjoitusasu
#map_30 <- rename_rows(map_30, 554, "Yli-Ii")

## Uusikirkko
take_a_look(map_30, "Uusikirkko")
map_30 <- rename_rows(map_30, 530, "Uusikirkko Tl", "697")
map_30 <- rename_rows(map_30, 618, "Uusikirkko Vl", "698")


## name = 1?
take_a_look(map_30, "1")
map_30 <- map_30 %>% filter(nimi != "1")


## resolve NAs
#     UNCOMMENT TO EXPLORE NA
# nas <- map_30 %>% filter(is.na(nimi)) %>% slice(2) %>% pull(rowid)
# temp <- st_touches(filter(map_30, is.na(nimi)), map_30)
# temp <- map_30 %>% slice(temp[[2]]) %>% pull(rowid)
# 
# kunnat <- map_30 %>% filter(rowid %in% temp | rowid == nas) 
# 
# kunnat %>% 
#   pull(rowid) %>% 
#  append(., c(461)) %>% 
#   take_a_look_rowid(map_30, .)
# kunnat %>% filter(!is.na(nimi)) %>% pull(nimi) %>% take_a_look(map_30, .)






## NA 141 Oravaiseen
kunnat
map_30 <- rename_rows(map_30, 141, "Oravainen", "470")

## poista NA 221 ja NA 294
kunnat
map_30 <- map_30 %>% filter(!rowid %in% c(221, 294))

## NA 459
map_30 <- rename_rows(map_30, 459, "Suursaari", "546")

## NA 460
map_30 <- rename_rows(map_30, 460, "Lavansaari", "433")


# correct the errors 1910 -------------------------------------------------


## Uusikirkko
take_a_look(map_10, "Uusikirkko")
map_10 <- rename_rows(map_10, 526, "Uusikirkko Tl", "697")
map_10 <- rename_rows(map_10, 474, "Uusikirkko Vl", "698")




# correct the errors 1901 -------------------------------------------------

## Uusikirkko
take_a_look(map_01, "Uusikirkko")
map_01 <- rename_rows(map_01, 494, "Uusikirkko Tl", "697")
map_01 <- rename_rows(map_01, 454, "Uusikirkko Vl", "698")



# correct the errors 1860 -------------------------------------------------

## Sonkajärvi ja Vieremä
plot_neighbors(map_60, "Vieremä")
map_60 %>% filter(nimi %in% naapurit(map_60, "Iisalmen mlk"))
map_60 <- rename_rows(map_60, 87, "Iisalmen mlk", "351")
map_60 <- rename_rows(map_60, 88, "Iisalmen mlk", "351")


## Euran kappeli ja Eura
map_60 %>% filter(nimi %in% "Eura")
map_01 %>% filter(nimi %in% c("Eura", "Euran kappeli", "Euran pitäjä"))
take_a_look(map_60, "Eura")
plot_neighbors(map_01, "Eura")
map_60 <- rename_rows(map_60, 244, "Euran kappeli", "653")


## Uusikirkko
map_60 %>% filter(nimi %in% "Uusikirkko")
plot_neighbors(map_60, "Uusikirkko")
map_60 <- rename_rows(map_60, 529, "Uusikirkko Vl", "698")

## resolve NAs
#
#     UNCOMMENT TO EXPLORE NA
# nas <- map_60 %>% filter(is.na(nimi)) %>% slice(1) %>% pull(rowid)
# temp <- st_touches(filter(map_60, is.na(nimi)), map_60)
# temp <- map_60 %>% slice(temp[[1]]) %>% pull(rowid)
# 
# kunnat <- map_60 %>% filter(rowid %in% temp | rowid == nas) 
# 
# kunnat %>% 
#   pull(rowid) %>% 
# #  append(., c(478, 494)) %>% 
#   take_a_look_rowid(map_60, .)
# kunnat %>% filter(!is.na(nimi)) %>% pull(nimi) %>% take_a_look(map_01, .)
# 
# take_a_look(map_01, naapurit(map_01, "Kemiö"))


## NA 446 Karijokeen
kunnat
map_60 <- rename_rows(map_60, 446, "Karijoki", "077")

## NA 495 Nurmoon
map_60 %>% filter(nimi == "Nurmo")
map_60 <- rename_rows(map_60, 495, "Nurmo", "469")

## NA 449 Maalahteen
kunnat
map_60 <- rename_rows(map_60, 449, "Maalahti", "151")

## NA 501 Särkisaloon
kunnat
map_60 <- rename_rows(map_60, 501, "Särkisalo", "548")

## NA 547 Angelniemi
map_01 %>% filter(nimi == "Angelniemi")
map_60 <- rename_rows(map_60, 547, "Angelniemi", "318")


# save --------------------------------------------------------------------

## put the maps back to the list
files[[1]] <- map_60
files[[2]] <- map_01
files[[3]] <- map_10
files[[4]] <- map_30
files[[5]] <- map_70

## correct ids
files <- map(files, ~ .x %>% mutate(id = str_pad(id, width = 3, pad = "0", side = "left" )))

save(files, file = "./mapdata/mapfiles_fixed_no_overlaps_or_errors")


# create shapefiles -------------------------------------------------------

## map data
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")


## Convert class
files <- map(files, as_Spatial)


## create new shapefiles

dsn <- "./new_shapefiles/"
map2(files, 1:length(files), 
     ~ writeOGR(.x, dsn = paste0(dsn, names(files))[.y],
                driver = "ESRI Shapefile", 
                layer = paste0("kunnat_", names(files))[.y],
                overwrite_layer = TRUE))

