## ---------------------------
##
## Script name: remove_overlaps
##
## Purpose of script: remove overlapping ares in the map shapefiles
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


## read mapdata
load("./mapdata/mapfiles_fixed")


## create maps
map_70 <- files %>% pluck(5)
map_30 <- files %>% pluck(4)
map_10 <- files %>% pluck(3)
map_01 <- files %>% pluck(2)
map_60 <- files %>% pluck(1)


# examine the overlaps ----------------------------------------------------
# 
#     UNCOMMENT TO EXPLORE THE OVERLAPS
#
# ## loop manually over each year
# j <- 1
# j <- j + 1
# 
# map <- files %>% pluck(j)
# 
# ## check overlapping areas
# overlaps <- which_overlaps(map)
# 
# ## select names
# names <- map(overlaps, ~ map %>% filter(rowid %in% .x) %>% pull(nimi))
# 
# ## go trhough each overlap manually 
# i <- 1
# i <- i + 1
# 
# ## take a look 
# take_a_look(map, names[[i]])


# remove overlaps 1860 ----------------------------------------------------

## check overlapping areas
overlaps <- which_overlaps(map_60)


## Iisalmen maalaiskunta ja kaupunki
map_60 <- remove_overlap(map_60, overlaps[[1]], "duplicate", 567) 
# säilytä kaupunki
# map <- remove_overlap(map, overlaps[[1]], "within") 


## Kemin maalaiskunta ja kaupunki
map_60 <- remove_overlap(map_60, overlaps[[2]], "duplicate", 569) 
map_60$nimi[map_60$nimi == "Kemi"] <- "Kemin mlk"
# säilytä kaupunki: 
# map <- remove_overlap(map, overlaps[[2]], "duplicate") 


## Nurmeksen maalaiskunta ja kaupunki
map_60 <- remove_overlap(map_60, overlaps[[3]], "duplicate", 574) 
# säilytä kaupunki: 
# map <- remove_overlap(map, overlaps[[3]], "duplicate") 


# remove overlaps 1901 ----------------------------------------------------

## check overlapping areas
overlaps <- which_overlaps(map_01)


## Kymi & Kotka
map_01 <- remove_overlap(map_01, overlaps[[1]], "duplicate", 488) 

## Kristiinankaupunki x2
map_01 <- remove_overlap(map_01, overlaps[[2]], "duplicate", 489) 

## Messukylä & Tampere
map_01 <- remove_overlap(map_01, overlaps[[3]], "within") 

## Hamina & Vehkalahti
map_01 <- remove_overlap(map_01, overlaps[[4]], "within") 

# remove overlaps 1910 ----------------------------------------------------

## check overlapping areas
overlaps <- which_overlaps(map_10)


## Pietarsaaren maalaiskunta ja kaupunki
map_10 <- remove_overlap(map_10, overlaps[[1]], "duplicate") 

## Iisalmen maalaiskunta ja kaupunki
map_10 <- remove_overlap(map_10, overlaps[[2]], "duplicate") 

## Nurmes
map_10 <- remove_overlap(map_10, overlaps[[3]], "duplicate", 511) 

## Kymi ja Kotka 
map_10 <- remove_overlap(map_10, overlaps[[4]], "duplicate", 514) 

## Lahti ja Hollola
map_10 <- remove_overlap(map_10, overlaps[[5]], "duplicate", 517) 

## Salo ja Uskela
map_10 <- remove_overlap(map_10, overlaps[[6]], "duplicate", 520) 

## Kristiinankaupunki x2
map_10 <- remove_overlap(map_10, overlaps[[7]], "duplicate", 521) 

## Messukylä & Tampere
map_10 <- remove_overlap(map_10, overlaps[[8]], "within") 

## Hamina & Vehkalahti
map_10 <- remove_overlap(map_10, overlaps[[9]], "within") 

## Vuolijoki
map_10 <- map_10 %>% filter(nimi != "Vuolijoki")

# remove overlaps 1930 ----------------------------------------------------

## check overlapping areas
overlaps <- which_overlaps(map_30)


## Remove 20 duplicate areas
remove <- c("Jäppilä", "Anttola", "Haukivuori", "Degerby", "Somerniemi", "Mietoinen", "Pihlajavesi", "Sahalahti", 
            "Viljakkala", "Metsämaa", "Vanaja", "Kullaa", "Jurva", "Ylimarkku", "Alaveteli", "Teerijärvi", "Hyvinkää",
            "Lohja", "Koivisto", "Pieksämäki")
remove_id <- c( 327, 330, 331, 335, 338, 349, 357, 359, 362, 369, 371, 378, 387, 390, 399, 401, 487, 490, 493, 505)
map_30 <- remove_overlap(map_30, method = "duplicate", which_to_remove = remove_id )

## Kouvola ja Valkeala
map_30 <- remove_overlap(map_30, overlaps[[17]], "duplicate", 473) 

## Valkeakoski ja Sääksmäki
map_30 <- remove_overlap(map_30, overlaps[[18]], "duplicate", 476) 

## Tuusula & Kerava
map_30 <- remove_overlap(map_30, overlaps[[19]], "duplicate", 479) 

## Jaakkima ja Lahdenpohja
map_30 <- remove_overlap(map_30, overlaps[[20]], "duplicate", 481) 

## Grankulla & Espoo
map_30 <- remove_overlap(map_30, overlaps[[21]], "duplicate", 484) 

## Rovaniemen maalaiskunta ja kaupunki
map_30 <- remove_overlap(map_30, overlaps[[25]], "duplicate") 

## Karjaan maalaiskunta ja kaupunki
map_30 <- remove_overlap(map_30, overlaps[[26]], "duplicate") 

## Kristiinankaupunki ja Tiukka
map_30 <- remove_overlap(map_30, overlaps[[28]], "within") 

## Hamina & Vehkalahti
map_30 <- remove_overlap(map_30, overlaps[[29]], "within") 

## Pietarsaaren mlk ja kaupunki
map_30 <- remove_overlap(map_30, overlaps[[30]], "duplicate", 619) 
map_30 <- remove_overlap(map_30, overlaps[[31]], "within") 

# check if outcome is correct ---------------------------------------------


## put the maps back to the list
files[[1]] <- map_60
files[[2]] <- map_01
files[[3]] <- map_10
files[[4]] <- map_30
files[[5]] <- map_70


## verify that all overlaps are removed
map(files, which_overlaps)


# save --------------------------------------------------------------------


## save it
save(files, file = "./mapdata/mapfiles_fixed_no_overlaps")
