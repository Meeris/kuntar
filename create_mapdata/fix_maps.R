## ---------------------------
##
## Script name: fix_maps
##
## Purpose of script: manipulate the map files
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


# load packages and functions -----------------------------------------------------------

source("./functions/functions.R")


# read data ---------------------------------------------------------------


## define the years
years <- c("1860", "1901", "1910", "1930", "1970")

## read data
files <- read_maps(years)
save(files,  file = "./mapdata/mapfiles")

class(pluck(files, 1))

## are the shapefiles valid? 
if(!any(map_lgl(files, gIsValid))) {
  print("Ainakin yksi kartta sisältää epävalideja polygoneja")
}

## Some files contain polygons that self-intersect, create a "buffer" with zero width to fix this
files <- map_if(files, ~ !gIsValid(.x), gBuffer,  width = 0, byid = TRUE)

## convert maps to class "simple feature"
files <- map(files, st_as_sf)

## see the variable names
map(files, names)

## change variable name, so the nams are consistent
files[[4]] <- files %>% pluck(4) %>% rename("nimi" = "kunta")

## select only variable name and geometry
files <- map(files, ~ .x %>% dplyr::select(one_of("nimi", "geometry")) )

## join id-numbers
ids <- read_csv("./data/ids.csv")
files <- map(files, ~ .x %>% left_join(ids))

## create rowid for identifying polygons
files <- map(files, ~ .x %>% rowid_to_column )

## save as a list
save(files, file = "./mapdata/mapfiles_fixed")







