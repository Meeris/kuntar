## ---------------------------
##
## Script name: functions_remove_overlaps
##
## Purpose of script: create functions for file "remove_overlaps"
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



# load packages -----------------------------------------------------------

#install.packages("devtools")
# devtools::install_github("yutannihilation/ggsflabel")
library(tidyverse)
library(sf)
library(ggsflabel)
library(grid)
library(gridExtra)


# identify ----------------------------------------------------------------


## This function identifies overlapping areas
which_overlaps <- function(map) {
  
  # initialize the list
  overlaps <- list()
  
  # loop over each polygon in a map and see if there are some polygons
  # that lie completely within another polygon
  for (i in 1:nrow(map)) {
    
    # select the rownumber of overlapping poygons
    temp <- st_covered_by(slice(map, i), map) %>% pluck(1)
    
    if(length(temp) > 1) {
      
      # use rowids instead of selecting by position
      temp <- map %>% slice(temp) %>% pull(rowid)
      
      # save in the list 
      overlaps[as.character(i)] <- list(temp)
      
    }
  }
  
  # print message
  if(is_empty(overlaps)) {
    print("Kartta ei sisällä päällekkäisyyksiä")
  } else {
    print("Kartta sisältää päällekkäisyyksiä")
    return(unique(overlaps))
  }
  
}

# neighbors ---------------------------------------------------------------

## This functions gives the names of the neighboring municipalities

naapurit <- function(map, kunta){
  
  # select the rownumbers of neighboring polygons
  temp <- st_touches(filter(map, nimi == kunta), map) %>% pluck(1)
  
  if(is.null(temp)) {
    print("Ei naapureita")
    return(NA)
  }
  
  # use names instead of selecting by position
  temp <- map %>% 
    slice(temp) %>% 
    pull(nimi) %>% 
    as.character() %>% 
    append(kunta)
  
  return(temp)
  
}

# view --------------------------------------------------------------------


## This function plots selected polygons
take_a_look <- function(map, names) {
  
  if(!any(names %in% map$nimi)) {
    return("Antamaasi kuntaa ei löydy kartasta")
  }

  map %>% 
    filter(nimi %in% names) %>%
    ggplot() +
    geom_sf(aes(fill = nimi, alpha = 0.5), show.legend = FALSE) +
    geom_sf_label_repel(
      aes(label = paste(nimi, rowid)),
      nudge_x = -5, nudge_y = -5, seed = 10) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())

}


# plot neigbors -----------------------------------------------------------

plot_neighbors <- function(map, name, neigh = TRUE) {
  
  if(neigh) {
    neib <- map(files, ~ naapurit(.x, name)) %>% unlist(use.names = FALSE) %>% unique() 
    neib <- neib[!is.na(neib)]
    neib <- append(neib, name)
    take_a_look(map, neib)
    
  } else {
    take_a_look(map, name)
  }

}


# compare -----------------------------------------------------------------

## This functions plots nice maps next to each other

compare_maps <- function(map_1, map_2, names, neighbors = FALSE) {
  
  # should neighbors be plotted?
  if(neighbors){
    
    # look for neighbors
    naapurit_1 <- naapurit(map_1, names[1])
    naapurit_2 <- naapurit(map_2, names[2])
    
    # check if one or both of them have no neighbors
    if(all(is.na(c(naapurit_1, naapurit_2)))) {
      print("Ei lainkaan naapureita")
    } else if (all(is.na(naapurit_1))) {
      naapurit_1 <- append(naapurit_2, names[1])
      print("Ensimmäisenä vuonna ei löytynyt naapureita")
    } else if(all(is.na(naapurit_1))) {
      naapurit_2 <- append(naapurit_1, names[2])
      print("Toisena vuonna ei löytynyt naapureita")
    }
    
    # create plots
    plot_1 <- take_a_look(map_1, naapurit_1)
    plot_2 <- take_a_look(map_2, naapurit_2)
    
    # otherwise create plots just with the given areas  
  } else {
    plot_1 <- take_a_look(map_1, names)
    plot_2 <- take_a_look(map_2, names)
  }
  
  ## plot
  grid.arrange(textGrob("ennen"), textGrob("jälkeen"), plot_1, plot_2, 
               ncol = 2, heights = unit(c(1, 20), c("in", "lines")))
}


# compare multiple --------------------------------------------------------

compare_many_maps <- function(list, name, neighbors = FALSE) {
  
  # should neighbors be plotted?
  if(neighbors){

    # look for neighbors
    neib <- map(list, ~ naapurit(.x, name)) %>% unlist(use.names = FALSE) %>% unique() 
    neib <- neib[!is.na(neib)]
  
    # plot with neighbors
    plots <- map(list, ~ take_a_look(.x, neib))
    
    # otherwise create plots just with the given areas  
  } else {
    plots <- map(list, ~ take_a_look(.x, name))
  }
  
  return(plots)
}


# remove overlaps ------------------------------------------------------------------

## This function removes overlapping

remove_overlap <- function(map, rowids, method, which_to_remove = "mlk") {
  
  # if method equals "within"
  if(method == "within") {
    
    # which polygon is bigger?
    areas <- st_area(filter(map, rowid %in% rowids))
    a <- rowids[which.max(areas)]
    b <- rowids[which.min(areas)]
    
    # get the difference of two polygons
    
    temp <- st_sym_difference(filter(map, rowid == a), 
                              filter(map, rowid == b)) %>%
      dplyr::select(one_of(colnames(map)))
    
    # remove the old polygon
    map <- map %>% filter(rowid != a)
    
    # and add the new one
    map <- rbind(map, temp)
    
    # if method equals "duplicate"
  } else if (method == "duplicate") {
    
    # which one should be kept?
    if(any(which_to_remove != "mlk")) {
      a <- which_to_remove
    } else{
      a <- rowids[str_detect(map$nimi[map$rowid %in% rowids], "mlk")]
    }
    
    # remove the unnecessary polygon
    map <- map %>% filter(!rowid %in% a)
  }
  
  return(map)
}



# remove errors -----------------------------------------------------------


rename_rows <- function(map, rowid,  new_name, new_id) {
  
  map$nimi[map$rowid %in% rowid] <- new_name
  map$id[map$rowid %in% rowid] <- new_id
  
  return(map)
  
}



# plot NAs ----------------------------------------------------------------


plot_nas <- function(map, which = 1) {

  if(!any(is.na(map$nimi))){
    return("Antamaasi ei löydy nimettömiä polygoneja")
  }
  
  print(paste("Kartassa on ", nrow(filter(map, is.na(nimi))), "nimetöntä polygonia"))
  
  map <- map_60
  map %>% 
    filter(is.na(map$nimi)) %>%
    slice(which) %>% 
    ggplot() +
    geom_sf(aes(fill = 1, alpha = 0.5), show.legend = FALSE) +
    geom_sf_label_repel(
      aes(label = paste(nimi, rowid)),
      nudge_x = -5, nudge_y = -5, seed = 10) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())

}




# take a look by rowids ---------------------------------------------------

take_a_look_rowid <- function(map, rowids) {
  
  if(!any(rowids %in% map$rowid)) {
    return("Antamaasi kuntaa ei löydy kartasta")
  }
  
  map %>% 
    filter(rowid %in% rowids) %>%
    ggplot() +
    geom_sf(aes(fill = nimi, alpha = 0.5), show.legend = FALSE) +
    geom_sf_label_repel(
      aes(label = paste(nimi, rowid)),
      nudge_x = -5, nudge_y = -5, seed = 10) +
    theme(axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank())
  
}


