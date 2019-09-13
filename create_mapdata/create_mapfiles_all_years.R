## ---------------------------
##
## Script name: create_mapfiles_all_years
##
## Purpose of script: Combine the two lists containing maps into one list and make projections 
##                    consistent.
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
library(tidyverse)
library(rgdal)
library(sf)
library(rgeos)


## data
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")
load("./mapdata/mapfiles_00")

# merge lists -------------------------------------------------------------


## merge the two mapfile lists
files <- append(files, files_00)


## select which Coordinate Reference System to use
## If you wish to follow the CRS of the most recent maps 
## instead of 1, type 2 inside of the function pluck()
crs <-  map(files, ~ st_crs(.x)) %>% unique() %>% pluck(1)


## reproject the new shapefiles using the CRS of old maps
files <- map_if(files, ~ st_crs(.x) != crs, ~ st_transform(.x, crs))


## check if the outcome is correct
map_lgl(files, ~ st_crs(.x) == crs)


## save
save(files, file = "./mapdata/mapfiles_all_years")






