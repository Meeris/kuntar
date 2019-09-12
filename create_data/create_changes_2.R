  ## ---------------------------
##
## Script name: create_changes_2
##
## Purpose of script: create a list of all the changes in municipality
##                    division between 1860 and 1970 based on crosswalk files 
##
## Author: Meeri Seppa
##
## Date Created: 2019-06-19
##
## Copyright (c) Meeri Seppä, 2019
## Email: meeri.seppa@helsinki.fi
##
## ---------------------------
##
## Notes: 
##    output: kuntamuutokset_1860_1970.csv
##
## ---------------------------



# load packages, functions and data -----------------------------------------------------------

library(readr)
source("./functions/functions.R")
load("./mapdata/mapfiles_fixed_no_overlaps")


# create the dataset by intersecting ------------------------------------------------------


## define the years
years <- names(files)

## loop over the years
for(i in c(1:(length(years) - 1))) {
  
  # get intersection
  temp <- get_intersection(files, years[i], years[i+1])
  
  # rename and select columns
  temp <- temp %>% 
    dplyr::select(contains("nimi"), contains("id"), kerroin ) %>% 
    rename_all(~ str_replace(., "[0-9]{4}", "liitetty_kunta"))

  # create a list column
  time_name <- paste(years[i], years[i + 1], sep = "-")
  temp <- tribble(~aika, ~data , time_name, temp)
  
  # add temp to the list
  if(i == 1) {
    changes <- temp
  } else {
    changes <- bind_rows(changes, temp)
  }
}


## ungroup, filter and create a new variable
changes <- changes %>%
  unnest() %>% 
  filter(kerroin > 0) %>% 
  mutate(kerroin_num = round(kerroin*100, 2)) 



# save ---------------------------------------------------------------------


## Save 
write_csv(changes, "./data/kuntamuutokset_1860_1970.csv")

