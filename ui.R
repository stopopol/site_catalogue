library(leaflet)

# Choices for drop-downs
vars <- c(
  "eLTER Site Category-Count" = "elter_count",
  "eLTER Site Category-Sub" = "elter_sub",
  "eLTER Site Category-Descriptive" = "elter_descriptive"
)

vars2 <- c(
  "Lithosphere" = "lithosphere",
  "Hydrosphere" = "hydrosphere",
  "Atmosphere" = "atmosphere",
  "Cryosphere" = "cryosphere"
)

ui <- fluidPage(
  
  tags$head(HTML("<title>eLTER Site Catalogue - Prototype</title>")),
  tags$head(tags$link(rel="eLTER Favicon", href="elter_favicon.ico")),
  
  titlePanel(title=div(img(height=60, width=60, src="elter_logo.svg"), "eLTER Site Catalogue (prototype)")),
  sidebarLayout(

    sidebarPanel(
      shinyjs::useShinyjs(),
      id = "side-panel",
      
      selectInput("elter_category", "eLTER Classification", vars, c("Select ..."), multiple=TRUE),
      selectInput("size", "Sphere (not doing anything atm)", vars2, c("Select ..."=""), multiple=TRUE),
      checkboxInput("socioeco", "Socio-economic data available", FALSE),
      verbatimTextOutput("value"),
      
      conditionalPanel(
        condition = "input.socioeco == '1'",
        sliderInput("popdensity", 
                  label = "Population density [people/km²]:",
                  min = min(fullSiteList$popdensity, na.rm = TRUE),
                  max = max(fullSiteList$popdensity, na.rm = TRUE), 
                  value = c(min(fullSiteList$popdensity, na.rm = TRUE), max(fullSiteList$popdensity, na.rm = TRUE)),sep = "",),
        sliderInput("avg_tillage", 
                    label = "Land under tillage [%]:",
                    min = min(fullSiteList$avg_tillage, na.rm = TRUE),
                    max = max(fullSiteList$avg_tillage, na.rm = TRUE), 
                    value = c(min(fullSiteList$avg_tillage, na.rm = TRUE), max(fullSiteList$avg_tillage, na.rm = TRUE)),sep = "",),
        
      ),
      actionButton("reset_input", "Reset filters"),
      tags$br(),tags$br(),
      downloadButton("download", "Download selected sites"),
      tags$br(),
      tags$br(),
      tags$div(id="cite", style="text-align: center; font-size: smaller;",
               'eLTER sites as of ', as.Date(file.info('data/lter_europe_sites.csv')$ctime)
      )
      
    ),       
    
    mainPanel(
      tabsetPanel(
        tabPanel("Map View", 
                 div(class="outer",
                     
                       tags$head(
                         # Include our custom CSS
                         includeCSS("styles.css"),
                       ),
                       
                       # If not using custom CSS, set height of leafletOutput to a number instead of percent
                       leafletOutput("map", width="100%", height = '80vh'),
                     
                    )
                 
                 ),
        tabPanel("Tabular View", DT::dataTableOutput("sitestable"))
      )
    )
  )
)
