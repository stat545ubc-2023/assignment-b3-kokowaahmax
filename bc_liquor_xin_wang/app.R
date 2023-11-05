#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(DT)

bcl <- read_csv("bc_liquor_data.csv")

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("BC Liquor Store App"),
  img(src = "img.png"),
  h4("Apply Filters Here"),
  sidebarLayout(
    sidebarPanel(
      # I modify the original slider input for price range to numerical input of min and max price. 
      # The most expensive liquor is 228000 CAD but most product are gathered in a lower price, 
      # which make the selection for cheaper product more difficult. So I made this change.
      numericInput("id_min_price", "Select Min Price: ", min = 0, value = 0),

      numericInput("id_max_price", "Select Max Price: ", min = 0, value = max(bcl$PRODUCT_PRICE)),
      
      # I added this widget for selecting the category of liquors, 
      # user can select multiple kinds of liquor and change in this widget will also change the UI.
      # User sometime need to specify the type of liquor to buy, add this widet can optimize their selection.
      selectInput("id_category", "Choose Category to Show",
                  choices = unique(bcl$ITEM_CATEGORY_NAME),
                  selected = unique(bcl$ITEM_CATEGORY_NAME),
                  multiple = TRUE),
      
      # I add this widget to let the user select the origin of liquor, change in this widgt will result in UI changes.
      # Users may have preference on where the liquor is coming from, adding this widget help with that.
      selectInput("id_origin", "Filter by Origin Country",
                  choices = c("All", unique(bcl$PRODUCT_COUNTRY_ORIGIN_NAME))),
      
      # I add this slider for user to select the container size of the liquor per container
      # This selection will benefit in gifting, user need to know how big is the liquor that they bought for a friend's dinner.
      sliderInput("id_volume_size", "Select Volume Size of the Product:",
                  min = 0, max = 20, value = c(0, 15), post = "Litres"),
      
      # This widget help with selecting the liquor with sweetness instruction, it will change the UI
      # Since not all liquor indicate the sweetness, this widget help with narrow the search that indicate the sweetness which can fit some customer needs.
      checkboxInput("id_sweetness", "Show Only Products with Sweetness Instruction", value = FALSE)
    ),
    mainPanel(
      # I added a download button for user to download the table result in csv, which contains only the result they selected. 
      # It can be helpful when the user narrowed to their final result and they can go to the store with only the information needed.
      # P.S: some business relevant info is not appeared in the table (like product sku number), but with downloaded .csv file user can retrive that.
      downloadButton("download_table", "Download Table as CSV"),
      h4("Number of Products vs Alcohol Percentage"),
      plotOutput("id_histogram"),
      h4("BC Liquor Detail"),
      DTOutput("id_table")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  bcl_filtered <-  reactive({
    filtered_data <- bcl %>%
      filter(PRODUCT_PRICE >= input$id_min_price,
             PRODUCT_PRICE <= input$id_max_price,
             PRODUCT_LITRES_PER_CONTAINER >= input$id_volume_size[1],
             PRODUCT_LITRES_PER_CONTAINER <= input$id_volume_size[2])

    if (input$id_sweetness) {
      filtered_data <- filtered_data %>%
        filter(!is.na(SWEETNESS_CODE))
    }

    if (!is.null(input$id_category)) {
      filtered_data <- filtered_data %>%
        filter(ITEM_CATEGORY_NAME %in% input$id_category)
    }

    if (input$id_origin != "All") {
      filtered_data <- filtered_data %>%
        filter(PRODUCT_COUNTRY_ORIGIN_NAME == input$id_origin)
    }

    filtered_data
  })
  
  output$download_table <- downloadHandler(
    filename = function() {
      paste("bc_liquor_table_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(bcl_filtered(), file)
    }
  )
  
  # I filled the histogram with the category of the alcohol, which gives a better information visualization 
  # and the user can clearly know the distribution of alcohol percentage and the liquor category.
  output$id_histogram <- renderPlot({
    bcl_filtered() %>%
      ggplot(aes(x = PRODUCT_ALCOHOL_PERCENT, fill = ITEM_CATEGORY_NAME)) +
      geom_histogram(binwidth = 2) +
      xlab("Alcohol Percentage") +
      ylab("Count") +
      labs(
        fill = "Category"
      )
  })

  # I filtered the table that only shows customer concerned data, other irrelevant information has been deselected for a better point of view.
  output$id_table <- renderDT({
    bcl_filtered() %>%
    select(
      Category = ITEM_CATEGORY_NAME,
      `Origin Country` = PRODUCT_COUNTRY_ORIGIN_NAME,
      `Product Name` = PRODUCT_LONG_NAME,
      `Alcohol Percentage` = PRODUCT_ALCOHOL_PERCENT,
      `Sweetness` = SWEETNESS_CODE,
      Liters = PRODUCT_LITRES_PER_CONTAINER,
      `Sell Unit` = PRD_CONTAINER_PER_SELL_UNIT,
      Price = PRODUCT_PRICE
    ) %>%
    datatable(
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
