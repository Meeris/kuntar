## ---------------------------
##
## Script name: create_maps_00
##
## Purpose of script: manipulate mapfiles for years 2013-2019
##
## Author: Meeri Seppa
##
## Date Created: 2019-07-15
##“
## Copyright (c) Meeri Seppa, 2019
## Email: meeri.seppa@helsinki.fi
##
## ---------------------------
##
## Notes: 
##   
##
## ---------------------------

## create mapfiles 2013-2019

## map data
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")


source("./functions/functions.R")

## define years
years  <- as.character(2013:2019)
files_00 <- read_maps(years)

class(pluck(files_00, 1))

## are the shapefiles valid? 
if(!any(map_lgl(files_00, gIsValid))) {
  print("Ainakin yksi kartta sisältää epävalideja polygoneja")
}


## convert maps to class "simple feature"
files_00 <- map(files_00, st_as_sf)

## see the variable names
map(files_00, names)

## select only variable name and geometry
files_00 <- map(files_00, ~ .x %>% dplyr::select(one_of("nimi", "geometry")) )

## join id-numbers
ids <- read_csv("./data/ids.csv")
files_00 <- map(files_00, ~ .x %>% left_join(ids))

## create rowid for identifying polygons
files_00 <- map(files_00, ~ .x %>% rowid_to_column )


## save as a list
save(files_00, file = "./mapdata/mapfiles_00")







