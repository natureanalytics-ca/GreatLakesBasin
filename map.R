# Define UI for map tab.
mapUI <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(
      12,
      mapboxerOutput(ns('map'), height=800),
      br(),
      radioButtons(
        ns('sel'),
        NULL,
        choiceNames = c('Vector Layer', 'Raster Layer'),
        choiceValues = c('vector_lyr', 'raster_lyr')
      )
    )
  )
}

# Define server logic
mapServer <- function(input, output, session) {
  ns <- session$ns
  vector_style <- list(
    "id" = "vector_lyr",
    "type" = "fill",
    "source" = "vector_src",
    "source-layer" = "owb_secondary",
    "paint" = list(
      "fill-color" = "#e41a1c",
      "fill-opacity" = 0.4,
      "fill-outline-color" = "#690E0E"
    ),
    "layout" = list(
      "visibility" = "visible"
    )
  )
  
  raster_style <- list(
    "id" = "raster_lyr",
    "type" = "raster",
    "source" = "raster_src",
    "layout" = list(
      "visibility" = "none"
    )
  )
  
  map <- mapboxer(
    center = c(-84.066, 45.727),
    zoom = 5,
    style = basemaps$Carto$positron
  ) %>%
    add_navigation_control() %>%
    add_source(
      mapbox_source(
        type = "vector",
        tiles = list("https://mappingon.ca/data2/owb_secondary/{z}/{x}/{y}.pbf")
      ),
      id = 'vector_src'
    ) %>%
    add_source(
      mapbox_source(
        type = "raster",
        tiles = list("https://mappingon.ca/data2/elev/{z}/{x}/{y}.pbf")
      ),
      id = 'raster_src'
    ) %>%
    add_layer(vector_style) %>%
    add_layer(raster_style)
  output$map <- renderMapboxer({map})
  
  observeEvent(input$sel, {
    sel <- req(input$sel)
    proxy <- mapboxer_proxy(ns("map"))
    for (lyr in c('vector_lyr', 'raster_lyr')) {
      if (lyr == sel) {
        proxy %>% set_layout_property(lyr, 'visibility', TRUE) %>% update_mapboxer()
      } else {
        proxy %>% set_layout_property(lyr, 'visibility', FALSE) %>% update_mapboxer()
      }
    }
  })
}