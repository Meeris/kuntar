## ---------------------------
##
## Script name: app
##
## Purpose of script: create app for project kuntaR
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



# load packages, functions and data ---------------------------------------

## packages
library(shiny)
library(ggplot2)
library(tidyverse)
library(leaflet)
library(readr)


## functions
source("./functions/functions.R")
source("./functions/functions_fix_maps.R")
source("./functions/functions_consistent.R")


## data
load("./mapdata/mapfiles_all_years")

fake_data_30 <- read_csv("./data/leikkidata_1930.csv")
fake_data_70 <- read_csv("./data/leikkidata_1970.csv")

  
## manipulate data
file_names <- c(list.files("./data/", ".csv"), list.files("./data/", ".txt"))
names(file_names) <- str_split_fixed(file_names, "\\.", 2)[, 1]

## merge the two mapfiles lists
#files <- append(files, files_00)


# ui ----------------------------------------------------------------------


ui <- navbarPage("Kuntarajat", 
                 
                 # merge crosswalk  -----------------------------------------------------------------------
                 
                 tabPanel("Crosswalk",
                          
                          fluidPage("", 
                                    
                                    # create sidebar layout
                                    sidebarLayout(
                                      
                                      # sidebar
                                      sidebarPanel(
                                        
                                        # title
                                        tags$h4("Crosswalk"),
                                        
                                        # instructions
                                        includeText("./instructions/inst_cross"),
                                        
                                        # Horizontal line 
                                        tags$hr(),
                                        
                                        # select years 
                                        fluidRow(column(4, selectInput("select_from_2", 
                                                                       label = h5("From"), 
                                                                       choices = names(files), 
                                                                       selected = "1930")),
                                                 
                                                 column(6, selectInput("select_to_2", 
                                                                       label = h5("To"), 
                                                                       choices = names(files),
                                                                       selected = "1970"))
                                        ),
                                        
                                        # set range for variable kerroin
                                        sliderInput("kerroin_2",  label = "Filter:",
                                                    min = 0, max = 100, value = c(1, 100)),
                                        
                                        #  or upload file
                                        fileInput("crosswalk_file", 
                                                  label = h5("or upload crosswalk"),
                                                  multiple = FALSE, accept = "text/csv",
                                                  buttonLabel = "Browse...",
                                                  placeholder = "No file chosen"),
                                        
                                        
                                        # Horizontal line 
                                        tags$hr(),
                                        
                                        tags$h4("convert data with crosswalk"),
                                        
                                        # select file
                                        radioButtons("file_select", 
                                                     label = h5("Choose"),
                                                     choices = list("aineisto 1930" = 1,
                                                                    "aineisto 1970" = 2),
                                                     inline = TRUE),
                                        
                                        # or upload file
                                        fileInput("file", label = h5("or upload a file"),
                                                  multiple = FALSE, accept = "text/csv",
                                                  buttonLabel = "Browse...",
                                                  placeholder = "No file chosen"),
                                        
                                        
                                        # instructions
                                        helpText("Supported file types are .txt ja .csv"),
                                        
                                        
                                        # action button
                                        actionButton("update", "Merge"),
                                        
                                        
                                        # Horizontal line 
                                        tags$hr(),
                                        
                                        # download
                                        tags$h4("Download files"),
                                        
                                        # choose dataset
                                        selectInput("dataset", "Choose dataset:",
                                                    choices = c("crosswalk", "yhdistetty aineisto")),
                                        
                                        # select format
                                        radioButtons("format", "Choose format",
                                                     choices = c(".csv"), 
                                                     inline = TRUE),
                                        
                                        # button
                                        downloadButton("downloadData", "Download"),
                                        
                                        # help
                                        tags$head(tags$script(src = "message-handler.js")),
                                        actionButton("help", "info")
                                        
                                        ),
                                      
                                      
                                      
                                      
                                      # main panel
                                      mainPanel(
                                        
                                        # show info about tables
                                        fluidRow(
                                          
                                          column(8, textOutput("crosswalk_info")),
                                          column(4, textOutput("table_to_merge_info"))
                                          
                                        ),
                                        
                                        tags$hr(),
                                        
                                        # show tables next to each other
                                        fluidRow(
                                          
                                          # show crosswalk
                                          column(8, tableOutput("crosswalk")),
                                          
                                          # show table to merge
                                          column(4, tableOutput("table_to_merge"))
                                          
                                        ),
                                        
                                        # horizontal line 
                                        tags$hr(),
                                        
                                        # show info
                                        textOutput("merged_table_info"),
                                        
                                        # show merged dataset
                                        DT::dataTableOutput("merged_table")
                                        
                                      )
                                    )
                          )
                 ),
                 

                 # create consistent -------------------------------------------------------
                 
                 tabPanel("Create consistent",
                          fluidPage("",

                                    sidebarLayout(
                                      sidebarPanel(
                                        
                                        # title
                                        tags$h4("Consistent areas"),
                                        
                                        # instructions
                                        includeText("./instructions/inst_cons"),
                                        
                                        # horisontal line
                                        tags$hr(),
                                        
                                        # select years 
                                        fluidRow(column(4, selectInput("select_from_3", 
                                                                       label = h5("From"), 
                                                                       choices = names(files), 
                                                                       selected = "1860")),
                                                 
                                                 column(6, selectInput("select_to_3", 
                                                                       label = h5("To"), 
                                                                       choices = names(files),
                                                                       selected = "1930"))
                                        ),
                                        
                                        # set range for variable kerroin
                                        sliderInput("kerroin_3",  label = "Filter",
                                                    min = 0, max = 100, value = c(5, 100)),
                                        
                                        fluidRow(
                                          
                                          # create button
                                          column(3, actionButton("create_cons", "Create")),
                                          column(9, helpText("Attention! This takes a while"))
                                          
                                          ),
                                        
                                        # horisontal line
                                        tags$hr(),
                                        
                                        radioButtons("show3", "Choose a feature",
                                                     choices = list("Show dataset" = 1,
                                                                 "Show the entire map" = 2,
                                                                 "Examine a certain area:" = 3)
                                                     ),
                                        
                                        # choose municipality
                                        textInput("name3", "",
                                                  value = "Write the municipality name..."),
                                        
                                        # horisontal line
                                        tags$hr(),
                                        
                                        # title
                                        tags$h5("Download the shapefile"),
                                        
                                        # download
                                        downloadButton("downloadData3", "Download")
                                        
                                      ),
                                      
                                      
                                      
                                      
                                      # main panel
                                      mainPanel(
                                        
                                        # show selecteddataset
                                        DT::dataTableOutput("show_cons_names"),
                                        
                                        # plot the maps
                                        plotOutput("map_cons")
                                        
                                      )
                                      
                                      
                                      
                                    )
                          )
                 ),
                 
                 
                 
                 
                 # browse datasets  -----------------------------------------------------------------------
                 
                 tabPanel("Browse datasets",
                          fluidPage("", 
                                    
                                    sidebarLayout(
                                      sidebarPanel(
                                        
                                        # instructions
                                        helpText("This tool allows you to take a closer look at any of the
                                                 dataset that were used in this project."),
                                        
                                        # select dataset
                                        radioButtons("choose_dataset", label = h5("Select a dataset"),
                                                     choices = as.list(file_names))
                                      ), 
                                      
                                      mainPanel(
                                        
                                        # show selected dataset
                                        DT::dataTableOutput("selected_dataset")
                                        
                                      )
                                      
                                    ))
                          ),
                 
                 
                 # browse maps  -----------------------------------------------------------------------
                 
                 tabPanel("Explore maps",
                          fluidPage("",
                                    
                                    sidebarLayout(
                                      sidebarPanel(
                                        
                                        # Title
                                        tags$h4("Maps"),
                                        
                                        # instructions
                                        includeText("./instructions/inst_maps"),
                                        
                                        # Horizontal line 
                                        tags$hr(),
                                        
                                        # select years
                                        radioButtons("years", label = h5("Choose a year"), 
                                                           choices = names(files), inline = TRUE),
                                        
                                        # Horizontal line 
                                        tags$hr(),
                                        
                                        # select activity
                                        radioButtons("show2", "Choose a feature:",
                                                     choices = list("Show the entire map" = 1,
                                                                    "Explore a certain area:" = 2)
                                        ),
                                    
                                        # choose municipality
                                        textInput("name",  label = "",
                                                  value = "Write the municipality name..."),
                                        
                                        # Show neighbors?
                                        checkboxInput("neigh", label = "Show neighbours")
                                      
                                      ),
                                      
                                      
                                      mainPanel(
                                        
                                        # plot the maps
                                        plotOutput("map")
                                        
                                      )
                                    
                                      )
                          
                          )
                                    
                          )
                          
                 )




# server ------------------------------------------------------------------

server <- function(input, output) {
  
  # merge crosswalk  -----------------------------------------------------------------------
  

  # get selected years 
  crosswalk_vars <- function() {
    
    from <- switch(input$select_from_2,
                   "1860" = 1860,
                   "1901" = 1901,
                   "1910" = 1910,
                   "1930" = 1930,
                   "1970" = 1970,
                   "2013" = 2013,
                   "2014" = 2014,
                   "2015" = 2015,
                   "2016" = 2016,
                   "2017" = 2017,
                   "2018" = 2018,
                   "2019" = 2019
                   )
    
    to <- switch(input$select_to_2, 
                 "1860" = 1860,
                 "1901" = 1901,
                 "1910" = 1910,
                 "1930" = 1930,
                 "1970" = 1970,
                 "2013" = 2013,
                 "2014" = 2014,
                 "2015" = 2015,
                 "2016" = 2016,
                 "2017" = 2017,
                 "2018" = 2018,
                 "2019" = 2019)
    return(c(from, to))
  }
  
  # get crosswalk 
  crosswalk <- function() {
    
    if(is.null(input$crosswalk_file)) {
      
      # get intersecction
      vars <- crosswalk_vars()
      data <- get_intersection(files, vars[1], vars[2])
      
      # filter
      data <- data %>% 
        filter(kerroin_p > input$kerroin_2[1],
               kerroin_p < input$kerroin_2[2])

    } else {
      data <- read_csv(input$crosswalk_file$datapath)
    }
    data
  }
  
  # get dataset
  merge_this_table <- function() {
    
    if(is.null(input$file)) {
      if(input$file_select == 1){
        data <- fake_data_30
      } else {
        data <- fake_data_70
      }
    } else {
      data <- read_csv(input$file$datapath)
    }
    
  }
  
  # datset info
  output$table_to_merge_info <- renderText({
    
    if(is.null(input$file)) {
      "Kuviteellista dataa vuoden 1930 kuntajaolla"
    } else {
      paste(input$file$name)
    }
  })
  
  # crosswalk info
  output$crosswalk_info <- renderText({
    vars <- crosswalk_vars()
    kerroin <- input$kerroin_2
    info <- paste("Crosswalk ", vars[1], " - ", vars[2], ". ", "Kerroin: ",
                  kerroin[1],"-", kerroin[2])
    info
  })
  
  # show datset
  output$table_to_merge <- renderTable( {
    data <- merge_this_table()
    head(data)
  })
  
  # show crosswalk
  output$crosswalk <- renderTable( {

  crosswalk() %>% head()
    
  })
  
  # merge tables function
  merge_table <- function() {

    cross <- crosswalk()
    
    # dataset to merge
    data <- merge_this_table()
    
    # merge the datsets
    merge_crosswalk(data, cross)
    
  }
  
  # show merged?
  show_merged_table <- eventReactive(input$update, {
    
    merge_table()
    
  })
  
  # show info 
  output$merged_table_info <- eventReactive(input$update, {
    
    
    vars <- crosswalk_vars()
    if(is.null(input$file)) {
      paste("Kuviteellista dataa muunnettuna vuoden 1930 kuntajaosta vuoden",
              vars[2], "kuntajaon mukaiseksi")
    } else {
      
      paste("Lataamasi aineisto", input$file$name, "muunnettuna vuoden", vars[1],
            "kuntajaosta vuoden", vars[2], "kuntajaon mukaiseksi")
    }
    
  })
  
  # show merged 
  output$merged_table <- DT::renderDataTable(DT::datatable(rownames = FALSE, { 

    show_merged_table()
    
  }))
  
  # get selected dataset
  datasetInput <- reactive({
    data <- switch(input$dataset,
                   "crosswalk" = "crosswalk",
                   "yhdistetty aineisto" = "merged")
    if(data == "crosswalk") {
      crosswalk()
    } else {
      merge_table()
    }
  })
  
  # download
  output$downloadData <- downloadHandler(
    
    filename = function() {
      if(input$dataset == "crosswalk") {
        paste0(input$dataset, "_", input$select_from_2, "_", input$select_to_2, ".csv")
      } else {
        paste0(input$dataset, ".csv")
      }
    },
    
    content = function(file) {
      if(input$format == ".csv") {
        write_csv(datasetInput(), file)
      } else if (input$format == ".xslx") {
        
      }
      
    }
  )
  
  # help
  observeEvent(input$help, {
    
    showModal(modalDialog(
      title = "Lisätietoa",
      "Crosswalk kertoo, miten kuntien rajat ovat muuttuneet tarkasteltavien vuosien välillä.
      Oleellisin osa crosswalkia on sen sisältämä kerroin. Kertoimen avulla nähdään, mikä osa ensimmäisen
      vuoden kunnasta kuuluu mihinkin jälkimmäisen vuoden kunnista. Kerroin muodostetaan vertaamalla 
      kuntien leikkauksien pinta-aloja ensimmäisen vuoden kunnan pinta-alaan.
      Crosswalk-tiedostot sisältävät monia havaintoja, joiden kerroin on lähellä nollaa. On hyvin
todennäköistä, että näin pienet arvot eivät kuvaa todellisia muutoksia kuntien rajoissa. Nämä 
havainnot sillä, ettei kuntien rajat ole täysin identtisiä karttojen välillä. On kuitenkin
hankala arvioida, minkä kokoisia kertoimia voidaan pitää liian pieninä. Olen jättänyt tarkastelun 
ulkopuolelle kaikki havainnot, joiden kerroin on alle yhden prosentin. ",
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  
  
  

  # create consistent -------------------------------------------------------
  
  # variables
  cons_vars <- function() {
    
    from <- switch(input$select_from_3,
                   "1860" = "1860",
                   "1901" = "1901",
                   "1910" = "1910",
                   "1930" = "1930",
                   "1970" = "1970",
                   "2013" = "2013",
                   "2014" = "2014",
                   "2015" = "2015",
                   "2016" = "2016",
                   "2017" = "2017",
                   "2018" = "2018",
                   "2019" = "2019")
    
    to <- switch(input$select_to_3, 
                 "1860" = "1860",
                 "1901" = "1901",
                 "1910" = "1910",
                 "1930" = "1930",
                 "1970" = "1970",
                 "2013" = "2013",
                 "2014" = "2014",
                 "2015" = "2015",
                 "2016" = "2016",
                 "2017" = "2017",
                 "2018" = "2018",
                 "2019" = "2019")
    return(c(from, to))
  }
  
  # consistent
  consistent <- function() {
    
    # get variables
    vars <- cons_vars()
    
    ## get consistent groups
    groups <- get_consistent(from = vars[1], to = vars[2], filter = input$kerroin_3[1])  
    #groups <- get_consistent(from = vars[1], to = vars[2], filter = 1)
    
    ## create map
    map_cons <- get_consistent_map(group = groups, map =  pluck(files, vars[2]))

    return(map_cons)
    
  }
  
  # create consistent map
  create_consistent <- eventReactive(input$create_cons, {
    
     consistent()
    
  })
  
  output$show_cons_names <- DT::renderDataTable(DT::datatable(rownames = FALSE, { 
    
    if(input$show3 == 1) {
      data <- create_consistent()
      data %>% as_tibble() %>%  dplyr::select(nimi)
    }
    
  }))
  
  # plot map_cons
  output$map_cons <- renderPlot({
    
    map_cons <- create_consistent()
    
    if(input$show3 == 2) {

      map_cons %>%
        ggplot() +
          geom_sf(aes(fill = nimi, alpha = 0.5), show.legend = FALSE) +
          theme(axis.title.x = element_blank(),
                axis.text.x = element_blank(),
                axis.ticks.x = element_blank(),
                axis.title.y = element_blank(),
                axis.text.y = element_blank(),
                axis.ticks.y = element_blank())

    } else if ( input$show3 == 3) {
      kunta <- map_cons$nimi[str_detect(map_cons$nimi, input$name3)]
      
      take_a_look(map_cons, kunta )
    }

  })
  
  # get selected dataset
  datasetInput3 <- reactive({
    
    ## get the map
    map <- consistent()
    
    ## map from class sf to spatial
    map <- as_Spatial(map)
    
    ## if polygons are not valid, fix them
    if(!gIsValid(map)) { 
      map <- gBuffer(map, width = 0, byid = TRUE)
    }
    
    return(map)
    
  })

  # download
  output$downloadData3 <- downloadHandler(

    filename = function() {
      paste0("consistentmap_", input$select_from_3, "_", input$select_to_3, ".zip")
    },

    content = function(file) {
      
      # get the data
      data <- datasetInput3()
      
      # create a temp folder for shp files
      temp_shp <- tempdir()
      
      # write shp files
      writeOGR(data,  temp_shp, paste0("cons_", input$select_from_3, "_", input$select_to_3),
               driver = "ESRI Shapefile")

      # zip all the shp files
      zip_file <- file.path(temp_shp, "shapefile.zip")
      shp_files <- list.files(temp_shp,
                              "cons",
                              full.names = TRUE)
      
      # zip it
      zip_command <- paste("zip -j", 
                           zip_file, 
                           paste(shp_files, collapse = " "))
      system(zip_command)
      
      # copy the zip file to the file argument
      file.copy(zip_file, file)
      
      # remove all the files created
      file.remove(zip_file, shp_files)

    }

  ) 


  # browse datasets  -----------------------------------------------------------------------
  
  # show dataset 
  output$selected_dataset <- DT::renderDataTable(DT::datatable(rownames = FALSE, { 
    
    name <- input$choose_dataset
    if(str_detect(name, "txt")) {
      read_delim(paste0("./data/", name), "\t", escape_double = FALSE, trim_ws = TRUE)
    } else {
      read_csv(paste0("./data/", name))
    }
    
  }))


  # browse maps -------------------------------------------------------------

  output$map <-  renderPlot({ 
    
    if(input$show2 == 1) (
      
      files %>% 
        pluck(input$years) %>% 
        ggplot() + 
        geom_sf(aes(fill = nimi, alpha = 0.5), show.legend = FALSE) +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              axis.title.y = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank())
    
    ) else {
      
      map <- files %>% pluck(input$years)
      
      plot_neighbors(map, input$name, input$neigh)

      
    }
    


    
  })
  

  
}



# app ---------------------------------------------------------------------

# Run the application 
shinyApp(ui = ui, server = server)

