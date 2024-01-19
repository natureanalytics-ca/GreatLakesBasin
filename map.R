# Define UI for map tab.
mapUI <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(
      12,
      mapboxerOutput(ns('map'), height=800),
      br(),
      fluidRow(
        column(
          6,
          checkboxGroupInput(
            ns('vectorSel'),
            'Vector Layers',
            selected = 'ca_watershed',
            choiceNames = as.vector(unlist(vector_layers)[grepl('.name',names(unlist(vector_layers)),fixed=T)]),
            choiceValues = names(vector_layers)
          )
        ),
        column(
          6,
          radioButtons(
            ns('rasterSel'),
            'Raster Layers',
            choiceNames = c(as.vector(unlist(raster_layers)[grepl('.name',names(unlist(raster_layers)),fixed=T)]), 'None'),
            choiceValues = c(names(raster_layers), 'none')
          )
        )
      )
    )
  )
}

# Define server logic
mapServer <- function(input, output, session) {
  ns <- session$ns

  # Render map
  map <- mapboxer(
    center = c(-84.066, 45.727),
    zoom = 5,
    minZoom = 4,
    maxZoom = 12,
    style = basemaps$Carto$positron
  ) %>%
    add_navigation_control() %>%
    
    # Add layer data sources from layers.R - note if any is defined wrong,
    # all will fail to display, without an error message.
    add_source(
      sources[['agriculture']],
      id = 'agriculture'
    ) %>%
    add_source(
      sources[['bathymetry']],
      id = 'bathymetry'
    ) %>%
    add_source(
      sources[['bathymetry_contour']],
      id = 'bathymetry_contour'
    ) %>%
    add_source(
      sources[['boundary']],
      id = 'boundary'
    ) %>%
     add_source(
       sources[['ca_watershed']],
       id = 'ca_watershed'
    ) %>%
     add_source(
       sources[['elevation']],
       id = 'elevation'
    ) %>%
    add_source(
      sources[['geology']],
      id = 'geology'
    ) %>%
    add_source(
      sources[['hillshade']],
      id = 'hillshade'
    ) %>%
    add_source(
      sources[['land_cover']],
      id='land_cover'
    ) %>%
    add_source(
      sources[['slope']],
      id = 'slope'
    ) %>%
    add_source(
      sources[['waterbody']],
      id = 'waterbody'
    ) %>%
    add_source(
      sources[['watercourse']],
      id = 'watercourse'
    ) %>%
    add_source(
      sources[['watershed']],
      id = 'watershed'
    ) %>%
    add_source(
      sources[['wetland']],
      id = 'wetland'
    ) %>%
    
    # Add layer styling from layers.R - layers are rendered in the order chosen
    # here i.e. the last layers are on top of others before them.
    add_layer(raster_layers[['elevation']][['style']]) %>%
    add_layer(raster_layers[['slope']][['style']]) %>%
    add_layer(raster_layers[['hillshade']][['style']]) %>%
    add_layer(raster_layers[['land_cover']][['style']]) %>%
    add_layer(raster_layers[['bathymetry']][['style']]) %>%
    add_layer(vector_layers[['us_farm_area']][['style']]) %>%
    add_layer(vector_layers[['on_farm_area']][['style']]) %>%
    add_layer(vector_layers[['us_geology']][['style']]) %>%
    add_layer(vector_layers[['on_geology']][['style']]) %>%
    add_layer(vector_layers[['bathymetry_contour']][['style']]) %>%
    add_layer(vector_layers[['us_watercourse']][['style']]) %>%
    add_layer(vector_layers[['on_watercourse']][['style']]) %>%
    add_layer(vector_layers[['us_waterbody']][['style']]) %>%
    add_layer(vector_layers[['on_waterbody']][['style']]) %>%
    add_layer(vector_layers[['us_wetland']][['style']]) %>%
    add_layer(vector_layers[['on_wetland']][['style']]) %>%
    add_layer(vector_layers[['us_county']][['style']]) %>%
    add_layer(vector_layers[['us_tract']][['style']]) %>%
    add_layer(vector_layers[['on_census_subdivision']][['style']]) %>%
    add_layer(vector_layers[['on_census_consolidated_subdivision']][['style']]) %>%
    add_layer(vector_layers[['on_census_division']][['style']]) %>%
    add_layer(vector_layers[['adm2']][['style']]) %>%
    add_layer(vector_layers[['owb_quaternary']][['style']]) %>%
    add_layer(vector_layers[['owb_tertiary']][['style']]) %>%
    add_layer(vector_layers[['owb_secondary']][['style']]) %>%
    add_layer(vector_layers[['owb_primary']][['style']]) %>%
    add_layer(vector_layers[['ca_watershed']][['style']]) %>%
    
    # Add mouseover tooltips from layers.R
    add_tooltips('us_farm_area', vector_layers[['us_farm_area']][['tooltip']]) %>%
    add_tooltips('on_farm_area', vector_layers[['on_farm_area']][['tooltip']]) %>%
    add_tooltips('us_geology', vector_layers[['us_geology']][['tooltip']]) %>%
    add_tooltips('on_geology', vector_layers[['on_geology']][['tooltip']]) %>%
    add_tooltips('bathymetry_contour', vector_layers[['bathymetry_contour']][['tooltip']]) %>%
    add_tooltips('us_watercourse', vector_layers[['us_watercourse']][['tooltip']]) %>%
    add_tooltips('on_watercourse', vector_layers[['on_watercourse']][['tooltip']]) %>%
    add_tooltips('us_waterbody', vector_layers[['us_waterbody']][['tooltip']]) %>%
    add_tooltips('on_waterbody', vector_layers[['on_waterbody']][['tooltip']]) %>%
    add_tooltips('us_wetland', vector_layers[['us_wetland']][['tooltip']]) %>%
    add_tooltips('on_wetland', vector_layers[['on_wetland']][['tooltip']]) %>%
    add_tooltips('us_county', vector_layers[['us_county']][['tooltip']]) %>%
    add_tooltips('us_tract', vector_layers[['us_tract']][['tooltip']]) %>%
    add_tooltips('on_census_subdivision', vector_layers[['on_census_subdivision']][['tooltip']]) %>%
    add_tooltips('on_census_consolidated_subdivision', vector_layers[['on_census_consolidated_subdivision']][['tooltip']]) %>%
    add_tooltips('on_census_consolidated_subdivision', vector_layers[['on_census_consolidated_subdivision']][['tooltip']]) %>%
    add_tooltips('on_census_division', vector_layers[['on_census_division']][['tooltip']]) %>%
    add_tooltips('adm2', vector_layers[['adm2']][['tooltip']]) %>%
    add_tooltips('owb_quaternary', vector_layers[['owb_quaternary']][['tooltip']]) %>%
    add_tooltips('owb_tertiary', vector_layers[['owb_tertiary']][['tooltip']]) %>%
    add_tooltips('owb_secondary', vector_layers[['owb_secondary']][['tooltip']]) %>%
    add_tooltips('owb_primary', vector_layers[['owb_primary']][['tooltip']]) %>%
    add_tooltips('ca_watershed', vector_layers[['ca_watershed']][['tooltip']]) %>%
  
    # Add mouse click popups from layers.R
    add_popups('us_farm_area', vector_layers[['us_farm_area']][['popup']]) %>%
    add_popups('on_farm_area', vector_layers[['on_farm_area']][['popup']]) %>%
    add_popups('us_geology', vector_layers[['us_geology']][['popup']]) %>%
    add_popups('on_geology', vector_layers[['on_geology']][['popup']]) %>%
    # add_popups('bathymetry_contour', vector_layers[['bathymetry_contour']][['popup']]) %>%
    # add_popups('us_watercourse', vector_layers[['us_watercourse']][['popup']]) %>%
    # add_popups('on_watercourse', vector_layers[['on_watercourse']][['popup']]) %>%
    add_popups('us_waterbody', vector_layers[['us_waterbody']][['popup']]) %>%
    add_popups('on_waterbody', vector_layers[['on_waterbody']][['popup']]) %>%
    add_popups('us_wetland', vector_layers[['us_wetland']][['popup']]) %>%
    add_popups('on_wetland', vector_layers[['on_wetland']][['popup']]) %>%
    add_popups('us_county', vector_layers[['us_county']][['popup']]) %>%
    add_popups('us_tract', vector_layers[['us_tract']][['popup']]) %>%
    add_popups('on_census_subdivision', vector_layers[['on_census_subdivision']][['popup']]) %>%
    add_popups('on_census_consolidated_subdivision', vector_layers[['on_census_consolidated_subdivision']][['popup']]) %>%
    add_popups('on_census_consolidated_subdivision', vector_layers[['on_census_consolidated_subdivision']][['popup']]) %>%
    add_popups('on_census_division', vector_layers[['on_census_division']][['popup']]) %>%
    add_popups('adm2', vector_layers[['adm2']][['popup']]) %>%
    add_popups('owb_quaternary', vector_layers[['owb_quaternary']][['popup']]) %>%
    add_popups('owb_tertiary', vector_layers[['owb_tertiary']][['popup']]) %>%
    add_popups('owb_secondary', vector_layers[['owb_secondary']][['popup']]) %>%
    add_popups('owb_primary', vector_layers[['owb_primary']][['popup']]) %>%
    add_popups('ca_watershed', vector_layers[['ca_watershed']][['popup']])
  
  output$map <- renderMapboxer({map})
  
  observe({
    sel <- input$rasterSel
    proxy <- mapboxer_proxy(ns("map"))
    for (lyr in c(names(raster_layers))) {
      if (lyr == sel) {
        proxy %>% set_layout_property(lyr, 'visibility', TRUE) %>% update_mapboxer()
      } else {
        proxy %>% set_layout_property(lyr, 'visibility', FALSE) %>% update_mapboxer()
      }
    }
  })
  observe({
    sel <- input$vectorSel
    proxy <- mapboxer_proxy(ns("map"))
    for (lyr in c(names(vector_layers))) {
      if (lyr %in% sel) {
        proxy %>% set_layout_property(lyr, 'visibility', TRUE) %>% update_mapboxer()
      } else {
        proxy %>% set_layout_property(lyr, 'visibility', FALSE) %>% update_mapboxer()
      }
    }
  })
}