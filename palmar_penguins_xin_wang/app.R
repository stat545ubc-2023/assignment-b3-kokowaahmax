#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(datateachr)
library(shiny)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(DT)
if (!require("palmerpenguins")) install.packages("palmerpenguins")
library(palmerpenguins)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Shiny App for Penguins at Palmer Station"),
  img(src = "img2.png"),
  h4("Apply Filters Here"),
  sidebarLayout(
    sidebarPanel(
      # I add the numerical input of min and max bill depth 
      # which helps user to filter bill depth and help user find the possible 
      # correlation of bill depth and other variable
      numericInput("id_min_bill_depth", "Select Min Bill Depth: ", min = 0, value = 0, step = 0.1),
      numericInput("id_max_bill_depth", "Select Max Bill Depth: ", min = 0, value = 22, step = 0.1),
      
      
      # I add this slider for user to select the bill length of penguins
      # This selection will benefit in researching, user need to know how long 
      # is the bill length that specific spice has.
      sliderInput("id_bill_length", "Select Bill length of the Penguines:",
                  min = 30, max = 60, value = c(32, 55), post = "mm"),
      
      # I added this widget for selecting the island of penguins, 
      # user can select multiple island and change in this widget will also change the UI.
      # User sometime need to find differences of penguins in different island to further explore the geological difference that influnce the penguins.
      selectInput("id_island", "Choise Located Island to show",
                  choices = unique(penguins$island),
                  selected = unique(penguins$island),
                  multiple = TRUE),
      
      # I add this widget to let the user select the year of data collected, change in this widgt will result in UI changes.
      # Users may have preference on which year the dataset is coming from to exclude the influnce from different years.
      selectInput("id_year", "Filter by Documented Year",
                  choices = c("All", unique(penguins$year))),
      
      
      # This widget help with selecting the penguins with no NA field, it will change the UI
      # Since not all penguins have full data, this widget help with narrow the search that has all variables.
      checkboxInput("id_full", "Show Only Penguins with full data", value = FALSE)
    ),
  
    mainPanel(
      # I added a download button for user to download the table result in csv, which contains only the result they selected. 
      # It can be helpful when the user narrowed to their final result and they can present with only the information needed.
      downloadButton("download_table", "Download Table as CSV"),
      h4("Number of Penguins vs Body Mass Weight"),
      plotOutput("id_histogram"),
      h4("Palmar Penguins Detail"),
      DTOutput("myTable"),
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  penguins_reactive <- reactive({
    filtered_data <- palmerpenguins::penguins %>%
      filter(bill_depth_mm >= input$id_min_bill_depth,
             bill_depth_mm <= input$id_max_bill_depth,
             bill_length_mm >= input$id_bill_length[1],
             bill_length_mm <= input$id_bill_length[2])
    
    if (input$id_full) {
      filtered_data <- filtered_data %>%
        filter(complete.cases(.))
    }
    
    if (!is.null(input$id_island)) {
      filtered_data <- filtered_data %>%
        filter(island %in% input$id_island)
    }
    
    if (input$id_year != "All") {
      filtered_data <- filtered_data %>%
        filter(year == input$id_year)
    }
    
    filtered_data
  })
  
  output$download_table <- downloadHandler(
    filename = function() {
      paste("palmer_penguins", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(penguins_reactive(), file)
    }
  )
  
  # I filled the histogram with the species of the penguins, which gives a better information visualization 
  # and the user can clearly know the distribution of species and the body mass weight.
  output$id_histogram <- renderPlot({
    penguins_reactive() %>%
      ggplot(aes(x = body_mass_g, fill = species)) +
      geom_histogram(binwidth = 100) +
      xlab("Weight") +
      ylab("Count") +
      labs(
        fill = "Species"
      )
  })

  # I filtered the table that only shows concerned data with clearer labels, which make the table more intuitive for the user.
  output$myTable <- renderDT({
    penguins_reactive() %>%
      select(
        Species = species,
        `Located Island` = island,
        `Bill Length (mm)` = bill_length_mm,
        `Bill Depth (mm)` = bill_depth_mm,
        `Weight (gram)` = body_mass_g,
        Gender = sex,
        `Documented Year` = year
      )%>% datatable(
        options = list(
          scrollX = TRUE,
          autoWidth = TRUE,
          columnDefs = list(list(className = 'dt-center', targets = "_all"))
        )
      ) 
  })
}

# Run the application
shinyApp(ui = ui, server = server)
