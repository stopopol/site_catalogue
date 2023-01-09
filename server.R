library(leaflet)
library(scales)
library(dplyr)
library(sf)
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(shinyjs)

function(input, output, session) {
  
  data <- reactive(
    spatial_frame_list <- sf::st_as_sf(x=fullSiteList, wkt="coordinates") %>%
      filter(
        is.null(input$elter_category) | elter_category %in% input$elter_category, # is needed to display all available value at beginning
        isFALSE(input$socioeco) | socioeco %in% input$socioeco, # check for Will's socioeco sites
        isFALSE(input$socioeco) | popdensity >= input$popdensity[1] & popdensity <= input$popdensity[2],
        isFALSE(input$socioeco) | avg_tillage >= input$avg_tillage[1] & avg_tillage <= input$avg_tillage[2],
      )
  )
  
  observeEvent(input$reset_input, {
    shinyjs::reset("side-panel")
  })

  ## Interactive Map ###########################################

  
  # Create the map
  output$map <- renderLeaflet({
    
    leaflet() %>%
      addTiles() %>%
      addMarkers(data = data()$coordinates,
                 popup = paste0('<a href="https://deims.org/',
                                data()$id_suffix,'" target="_blank">',data()$title,'</a>'),
                 #clusterOptions = markerClusterOptions()
      ) %>%
      #setView(lng = 15, lat = 50, zoom = 4),
      fitBounds(-15, 30, 40, 70) # roughly zoomed to Europe + Israel
  })

  ## Data Explorer ###########################################

  output$sitestable <- DT::renderDataTable({
 
    cleantable <- data() %>%
      select(
        "Title" = title,
        "DEIMS.iD" = id_suffix,
        "eLTER Category" = elter_category,
      )
    
    cleantable$coordinates <- NULL

    # check for empty dataframe
    if (dim(cleantable)[1] != 0) {
      url_string <- paste0("www.deims.org/", cleantable$DEIMS.iD)
      cleantable$DEIMS.iD <- paste0("<a href='https://",url_string,"'>", url_string,"</a>")
      cleantable$Longitude <- as.numeric(gsub(".*?([-]*[0-9]+[.][0-9]+).*", "\\1", data()$coordinates))
      cleantable$Latitude <- as.numeric(gsub(".* ([-]*[0-9]+[.][0-9]+).*", "\\1", data()$coordinates))
    }
    
    action <- DT::dataTableAjax(session, cleantable, outputId = "sitetable")
    DT::datatable(cleantable, options = list(ajax = list(url = action)), escape = FALSE)
  })
  
  ## Export ##########################
  output$download <-
    downloadHandler(
      filename = function () {
        paste("selected_elter_sites.csv", sep = "")
      },
      
      content = function(file) {
        write.csv(data(), file)
      }
    )
}
