## ---------------------------
##
## Script name: create_consistent
##
## Purpose of script: create area within which there occur no changes 
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
##   some problems: luovuteulla alueella, korjaus 1%?
##                  
## ---------------------------



# load packages, functions  and data -----------------------------------------------------------


## Check if required packages exist. Install them before loading if needed
if (!require("pacman")) install.packages("pacman")
p_load("ggplot2", "rgdal", "dplyr", "sf", "rgeos", "raster", "purrr",
       "tidyr", "readr")

## functions
source("./functions/functions_consistent.R")


## map data
load("./mapdata/mapfiles_fixed_no_overlaps_or_errors")



# create a map of consistent areas ---------------------------------------------------------------------


## initialize the list
maps <- as.list(c("1970", "1930"))
names(maps) <- c("1860_1970", "1860_1930")

## get consistent groups
maps <- map(maps, ~ get_consistent(from = "1860", to = .x, filter = 5)  )

## create map
maps <- map(maps, ~ get_consistent_map(group = .x, map = pluck(files, 4) ))



# Consistent? -------------------------------------------------------------


## are the plogyons valid? 
maps <- map(maps, as_Spatial)
ifelse(map_lgl(maps, gIsValid), "Kartta on validi", "Kartassa on jotain vialla")

## if not, fix them
maps <- map_if(maps, ~ !gIsValid(.x), gBuffer,  width = 0, byid = TRUE)



# plot it -----------------------------------------------------------------

maps %>% pluck(1) %>% st_as_sf() %>%  ggplot() + geom_sf()
maps %>% pluck(2) %>% st_as_sf() %>%  ggplot() + geom_sf()



# save --------------------------------------------------------------------

dsn <- "./shapefiles_new/consistent_"

map2(maps, c(1:2), 
     ~ writeOGR(.x, dsn = paste0(dsn, names(maps))[.y],
              driver = "ESRI Shapefile", 
              layer = paste0("cons_", names(maps))[.y],
              overwrite_layer = TRUE))



