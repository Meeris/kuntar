## ---------------------------
##
## Script name: create_croswalk
##
## Purpose of script: create crosswalk files
##
## Author: Meeri Seppa
##
## Date Created: 2019-07-11
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




# packages functions and data ---------------------------------------------


## packages
library(tidyverse)


## functions
source("./functions/functions.R")


## map data
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")
load("./mapdata/mapfiles_00")
load("./mapdata/mapfiles_all_years")


# Create crosswalks  -------------------------------------------------------

cross <- map(names(files)[2:12],
             ~ get_intersection(files = files, to = "1860", from = as.character(.x)))

cross <- map(cross,~ .x %>% filter(kerroin > 0.01))


map(files, ~ head(files))
temp <- get_intersection(files, from = 2013, to = 2019)
temp <- get_intersection(files, from = 1970, to = 2019)
temp <- temp %>% filter(kerroin > 0.01)


files[[10]] %>% ggplot() + geom_sf()
files[[1]] %>% ggplot() + geom_sf()

# save --------------------------------------------------------------------

dsn <- "./crosswalk_files/crosswalk_1860_"

map2(cross, names(files)[2:5], ~ write_csv(.x, path = paste0(dsn, .y )))




