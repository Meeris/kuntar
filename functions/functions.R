## ---------------------------
##
## Script name: functions
##
## Purpose of script: create functions for project "kuntaR"
##
## Author: Meeri Seppa
##
## Date Created: 2019-06-19
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



## load packages -----------------------------------------------------------


library(ggplot2)
library(rgdal)
library(dplyr)
library(rgeos)
library(sf)
library(raster)
library(purrr)
library(tidyr)
library(stringr)
library(tibble)


## create a function to read shapefiles -----------------------------------------------------------
#
#  This function reads shapefiles from defined years, merges two shapefiles together if necessary.
#  Checks if shapefiles are valid, if not creates a buffer to fix the problem. Returns a list. 
#  Specially designed for this project. See the path. 
#
#  The following warnings can be ignored:
#    In readOGR(dsn, encoding = "UTF-8") : Z-dimension discarded
#    In RGEOSUnaryPredFunc(spgeom, byid, "rgeos_isvalid") :
#      Self-intersection at or near point X
#    In all(map(files, gIsValid)) : coercing argument of type 'list' to logical
# encoding sfould be UTF-8 on windows and "ISO-8859-1" in mac


read_maps <- function(years, dsn = "./shapefiles_old/Kunnat_") {
  
  # select encoding
  en <- "ISO-8859-1" # Mac
  #en <- "UTF-8" # Windows
  
  # create a list for the files
  files <- list()
  
  # there are two folders for years 1901 and 1910, select the newer
  years <- map_if(years, years %in% c("1901", "1910"), ~ paste0(.x, "_uusi"))
  
  # loop over the selected years (files)
  for (i in years) {
    
    # read the names of the shapefiles in that year
    cat("\n", paste("reading data for year", i), "\n")
    filenames <- dir(paste0(dsn, i), ".shp")
    
    # are there any shapefiles?    
    if(is_empty(filenames)) {
      print(paste("The file for the year", i, "does not exist"))
      print(paste0(dsn, i))
      
      # if there are many files, combine regions and ellipses   
    } else if(length(filenames) > 1) {
      filenames <- filenames[str_detect(filenames, i)]
      temp <- raster::bind(readOGR(paste0(dsn, i, "/", filenames[1]), encoding = en),
                           readOGR(paste0(dsn, i, "/", filenames[2]), encoding = en))
      print(paste("There were two files in year", i))
      
      # otherwise, read the shapefile  
    } else {
      print(paste0(dsn, i, "/", filenames))
      temp <- readOGR(paste0(dsn, i, "/", filenames), encoding = en)
    }
    
    # save the file in the list
    files[[which(years == i)]] <- temp
    
  }
  
  # rename the years again if necessary
  years <- map(years, ~ str_extract(.x, "[0-9]{4}"))
  
  # name the objects
  names(files) <- years
  
  # rename so variable names are consistent (1930 file uses "kunta" instead of "nimi")
  # if(any(names(files) == "1930")) {
  #   names(files$"1930")[2] <- "nimi" 
  # }
  
  # are the shapefiles valid? Some files contain polygons that self-intersect
  # create a "buffer" with zero width to fix this
  #files <- map_if(files, ~ !gIsValid(.x), gBuffer,  width = 0, byid = TRUE)

  # convert to sf
  #files <- map(files, st_as_sf)
  
  return(files)
}


## create a function to define intersecting areas ---------------------------------------------------------------
#
#  This function takes a list of spatial polygons as an argument. It then creates a crosswalk for defined years. Additionally, 
#  it will give the name of each observation in all years.
#  warning "Unknown columns: `Aluetunnus`" can be ignored
#

get_intersection <- function(files, from, to) {
  
  # create new variables "area"
  files <- map(files, ~ .x %>%
                 mutate(area = as.numeric(st_area(.x))) %>% 
                 group_by(nimi) %>% 
                 mutate(area = sum(area)) %>% 
                 ungroup())
  
  # select years
  years <- as.character(c(to,from))

  # intersection
  int <- st_intersection(files[[years[1]]], files[[years[2]]])
  
  # area again
  int$area_int <- as.numeric(st_area(int))
  
  # calculate the multiplier
  int <- int %>% mutate(kerroin = area_int/area.1)
  
  # convert factor variables and id numbers to charachter
  int <- int %>% 
    mutate_if(is.factor, as.character) %>% 
    mutate_if(str_detect(colnames(.), "id"), str_pad, width = 3, pad = "0", side = "left")
  
  # select which variables to keep
  keep <- c("nimi", "id", "nimi.1", "id.1", "kerroin") 
  int <- int %>%
    as_tibble() %>% 
    dplyr::select(one_of(keep))
  
  # new variable names
  new_names <- tibble(x = keep, y = keep) %>% 
    mutate_all(tolower) %>% 
    mutate(x = str_replace(x, ".1", paste0("_", from))) %>% 
    filter(y %in% colnames(int)) %>%            
    deframe()
  
  # rename 
  int <- int %>% 
    rename(!!new_names)
  
  # new variable kerroin%
  int <- int %>% 
    mutate(kerroin_p = round(kerroin * 100, 1))
  
  # int <- int %>% mutate_if(str_detect(., "id"), as.character())

  # return the dataset
  return(int)
  
}

# Intersection with more information --------------------------------------

get_intersection_extra <- function(files, from, to) {
  
  # create new variables "area"
  files <- map(files, ~ .x %>%
                 mutate(area = as.numeric(st_area(.x))) %>% 
                 group_by(nimi) %>% 
                 mutate(area = sum(area)) %>% 
                 ungroup())
  
  # select years
  years <- as.character(c(to,from))
  
  # intersection
  int <- st_intersection(files[[years[1]]], files[[years[2]]])
  
  # area again
  int$area_int <- as.numeric(st_area(int))
  
  # calculate the multiplier
  int <- int %>% mutate(kerroin = area_int/area.1)
  
  # convert factor variables to charachter
  int <- int %>% 
    mutate_if(is.factor, as.character) 
  
  # return the dataset
  return(int)
  
}


# crosswalk ---------------------------------------------------------------

merge_crosswalk <- function(data, crosswalk) {
  
  # get names for merging
  keep <- names(crosswalk)[ names(crosswalk) %>% str_detect("[0-9]{4}") ] 
  names(keep) <- names(data)[ names(data) %in% names(crosswalk) ] 
  
  # merge the files
  temp <- data %>%
    left_join(crosswalk, by = keep) 
  
  # add missing multipliers
  temp$kerroin[is.na(temp$kerroin)] <- 1
  
  # sum the multipliers
  merged <- temp %>% 
    group_by(nimi.y) %>% 
    mutate(muuttuja = sum(muuttuja * kerroin)) %>% 
    dplyr::select(nimi.y, id.y, muuttuja) %>% 
    distinct()
  
  # rename 
  names(merged) <- c("nimi",  "id", "muuttuja")
  
  return(merged)
}







