## ---------------------------
##
## Script name: functions_consistent
##
## Purpose of script: functions for file create_consistent
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


# Packages  ---------------------------------------------------------------


if (!require("pacman")) install.packages("pacman")
p_load("ggplot2", "rgdal", "dplyr", "sf", "rgeos", "raster", "purrr",
       "tidyr", "readr", "tidyverse")


# list of consistent groups ----------------------------------------

get_consistent <- function(from, to, filter = 1) {
  
  ## create temp
  cons <- read_csv("./data/kuntamuutokset_1860_2019.csv", guess_max = 6000)
  
  ## filter out the unmeaningful changes 
  cons <- cons %>% 
    filter(kerroin_num > filter) 
  
  ## select the years 
  years <- unique(cons$aika)
  years <- years[last(which(str_detect(years, from))):
                   first(which(str_detect(years, to)))]
  
  
  ## check what changes took place in each time period
  for (year in years) {
    
    # group the data by year
    temp <- cons %>% 
      filter(aika == year) %>% 
      group_by(id_liitetty_kunta) %>%
      nest()
    
    # select each name-id only once
    temp <- temp %>% 
      transmute(liitos = map(temp$data, ~ unique(.x$id)), 
                id_liitetty_kunta)
    
    # name the column
    colnames(temp)[1] <- paste("liitos", year, sep = "_")
    
    # join the column to original dataset 
    cons <- cons %>% left_join(temp, by = c("id" = "id_liitetty_kunta"))
    
  }
  
  ## merge all the changes from previosly created columns into a one column
  
  ## group and nest the data
  temp <- cons %>% 
    dplyr::select("nimi_liitetty_kunta", "id_liitetty_kunta", starts_with("liitos")) %>% 
    gather(x, liitos, c(2:length(.)) ) %>% 
    dplyr::select(-x) %>% 
    group_by(nimi_liitetty_kunta) %>% 
    nest()
  
  ## create a list column containing only one vector for each row
  cons <- temp %>% 
    mutate(liitokset_all =  map(temp$data,  ~ unique(unlist(.x, use.names = FALSE)))) %>%
    dplyr::select(-data) %>% 
    left_join(cons, .)
  
  
  ## check which groups intersect, then make an union of them 
  
  ## which name-ids appear in the dataset?
  ids <- unique(unlist(cons$liitokset_all))
  
  ## initialise a new column
  cons <- cons %>%  mutate(group = liitokset_all)
  
  ## go trough each id and make an union of all the rows that they appear
  for(i in ids) {
    a <- which(map_lgl(cons$group, ~ i %in% .x ))
    if(!is_empty(a)) {
      b <- reduce(cons$group[a], union)
      cons$group[a] <- list(b)
    }
    
  }
  
  ## Now each id should appear once
  cons$group <- map(cons$group, as.numeric)
  cons$liitokset_all <- map(cons$liitokset_all, as.numeric)
  
  a <- sum(unlist(unique(cons$group)), na.rm = TRUE)
  b <- sum(unique(unlist(cons$liitokset_all)))
  if(a == b) {
    print("Kuntaryhmät eivät sisällä päällekäisyyksiä")
  }
  
  ## select the groups and store them into a list
  groups <- cons %>% 
    filter(aika == "1930-1970") %>% 
    dplyr::select(group) %>% 
    pull() %>% 
    unique()
  
  # make sure that there are no duplicates
  if(any(duplicated(unlist(groups)))) {
    print("Jotain on mennyt pieleen")
  }
  
  groups <- map(groups, ~ str_pad(.x, width = 3, pad = "0", side = "left" ))
  
  return(groups)
  
}


# name for consistent group -----------------------------------------------

get_consistent_names <- function(group){
  
  ## read id numbers and names from file
  ids <- read_csv("./data/ids.csv")
  
  ## get the names
  names <- map(group, ~ ids %>% filter(id %in% .x) %>% pull(nimi))
  
  return(names)
}


# map object --------------------------------------------------------------

get_consistent_map <- function(group, map) {
  
  ## merge the polygons in each group into one
  map_cons <- map_dfr(group, ~ map %>%
                        filter(id %in% .x) %>% 
                        st_union() %>%
                        as.tibble())
  
  ## coerce into an sf object and create rowids
  map_cons <-  
    map_cons %>% 
    st_as_sf() %>% 
    rowid_to_column() %>% 
    mutate(nimi = as.character(rowid))
  
  
  ## projection
  st_crs(map_cons) <- st_crs(map)
  
  ## names
  names <- get_consistent_names(group)
  names <- map_chr(names, ~ paste(.x, collapse = "-"))
  
  map_cons <-  
    map_cons %>% 
    mutate(nimi = names)
  
  return(map_cons)
  
}


