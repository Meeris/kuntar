## ---------------------------
##
## Script name: create_kunnat_2.0
##
## Purpose of script: create identification numbers for municipalities
##
## Author: Meeri Seppa
##
## Date Created: 2019-07-15
##
## Copyright (c) Meeri Seppa, 2019
## Email: meeri.seppa@helsinki.fi
##
## ---------------------------
##
## Notes: 
##  this script also creates the following datasets:
##    olemassa_olevat_kunnnat_2019.csv
##    lakkautetut_kunnnat_2019_tilastokeskus.csv
##    kartoissa_olevat_kunnat.csv
## ---------------------------




# load packages and functions -----------------------------------------------------------


## Check if required packages exist. Install them before loading if needed
if (!require("pacman")) {install.packages("pacman")}
p_load("readr", "tidyr", "dplyr", "lubridate", "stringr", "tibble")


## functions
source("./functions/functions.R")


# read data from web -----------------------------------------------------------


## get a list of existing municipalities
url <- "http://www.stat.fi/meta/luokitukset/kunta/001-2019/tekstitiedosto.txt"
kunnat_tk <- read_delim(url, "\t", escape_double = FALSE,
                          locale = locale(encoding = "ISO-8859-1"),
                          trim_ws = TRUE, skip = 2)

## save it
write_csv(kunnat_tk, "./data/olemassa_olevat_kunnnat_2019.csv")


## get a list of municipalities that no longer exist
url <- "http://www.stat.fi/meta/luokitukset/_linkki/lakkautetut_kunnat_aakkosissa_15.txt"
ceased <- read_delim(url, "\t", escape_double = FALSE,
                     locale = locale(encoding = "ISO-8859-1"), 
                     na = "-", trim_ws = TRUE) %>% 
  full_join(read_table2("./data/kuntaliitokset_2015-2018.txt", 
                        col_types = cols(Lakkautuskunta = col_character())))

## save it 
write_csv(ceased, "./data/lakkautetut_kunnnat_2019_tilastokeskus.csv")


## add changes after 2015 manually (this is made in kuntaliitokset_2015-2018.txt)
## read more here: http://www.stat.fi/meta/luokitukset/kunta/001-2019/kuvaus.html


# read data from maps -----------------------------------------------------------

## define the years
years <- c("1860", "1901", "1910", "1930", "1970")

## read data
files <- read_maps(years)

## change variable name, so the names are consistent
names(files[[4]])[names(files[[4]]) %in% "kunta"] <- "nimi"

## create a dataframe with municipality names 
kunnat_maps  <- map_df(files, ~ tibble(nimi = .x$nimi)) %>%
  distinct() 

## save it
write_csv(kunnat_maps, "./data/kartoissa_olevat_kunnat.csv")

# Identification numbers  --------------------------------------------------------

## join the datasets
ids <- kunnat_tk %>% 
  full_join(ceased, by = c("koodi" = "Lakkautuskunta", "nimike" = "Nimike")) %>% 
  transmute(nimi = nimike) %>% 
  full_join(kunnat_maps) %>% 
  distinct() 

## add another Uusikirkko
ids <- bind_rows(ids, 
                 tibble(nimi = c("Uusikirkko Tl", "Uusikirkko Vl")))


## create id numbers
ids <- ids %>%
  rownames_to_column("id") %>% 
  mutate(id = str_pad(id, width = 3, pad = "0", side = "left" )) 


# save the dataset  -----------------------------------------------------------

write_csv(ids, "./data/ids.csv")

