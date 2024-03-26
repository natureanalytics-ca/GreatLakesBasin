# Define UI for map tab.
mapUI <- function(id) {
  ns <- NS(id)
  tagList(
    div (
      style="display: flex; flex-direction: row; flex-wrap: wrap; width: 100%; align-items: stretch; padding: 0rem 7.5px 10px 7.5px;",
      #column 1
      div(
        style = "
          flex-grow: 100; 
          align-content: stretch; 
          background:
            linear-gradient(
              to right, 
              #c20430 0%,
              #fcfcfc 100%
               
            )
            left 
            bottom
            no-repeat; 
          border-radius: 3px; 
          border-style: none; 
          color: #343a40;
          
          margin: 0px; 
          padding: 5px 20px;",
        div(
          style = "color: white;",
          "Laurentian Great Lakes"
        )
      ),
      
      #column 2
      div(style="display: flex; flex-direction: row; justify-content: flex-end; flex-grow: 1;",
          shinyWidgets::dropdown(
            style = "simple",
            status = "royal",
            icon = icon('info'),
            right = TRUE,
            size = "md",
            div(
              style = "width: 500px; padding: 20px;",
              h6("Great Lakes visualization tool"),
              tags$small("Prototype for gathering, processing, and simple visualization of spatial data for Laurentian Great Lakes.")
            )
          )
          
      )
    ),
    
    tabBox(
      title = "",
      maximizable = FALSE,
      collapsible = FALSE,
      collapsed = FALSE,
      width = 12,
      solidHeader = FALSE,
      status = NULL,
      type = "tabs",
      tabPanel(
        title = icon("location-dot"),
        fluidRow(
          column(
            1,
            div(
              align = "center",
              style = "
                height: 100%; 
                min-width: 35px;
                max-width: 50px;
                background:
                linear-gradient(
                  to bottom, 
                  #343a40 0%,
                  #343a4050 100%
                )
                no-repeat; 
                border-radius: 5px; 
                border-style: none; 
                ",
              div(
                align = "left",
                shinyWidgets::dropdown(
                  style = "simple",
                  status = "default",
                  size = "lg",
                  width = "400px",
                  icon = icon("road"),
                  tooltip = tooltipOptions(title = "Contextual layers"),
                  pickerInput(
                    ns('vectorSel'),
                    label = 'Contextual layers (select up to 2)',
                    multiple = TRUE,
                    choices = setNames(
                      names(vector_layers),
                      as.vector(unlist(vector_layers)[grepl('.name',names(unlist(vector_layers)),fixed=T)])
                    ),
                    options = pickerOptions(
                      dropdownAlignRight = 'auto',
                      maxOptions = 2,
                      maxOptionsText = "Select up to 3",
                      style = 'color: #343a40;'
                    )
                  ),
                  hr(),
                  uiOutput(ns("vecCol1")),
                  br(),
                  uiOutput(ns("vecCol2")),
                  br(),
                  uiOutput(ns("vecCol3"))
                ),
                shinyWidgets::dropdown(
                  style = "simple",
                  status = "default",
                  size = "lg",
                  width = "400px",
                  icon = icon("map"),
                  tooltip = tooltipOptions(title = "Base layers"),
                  pickerInput(
                    ns('rasterSel'),
                    'Base layers (select one)',
                    multiple = TRUE,
                    choices = setNames(
                      c(names(raster_layers)),
                      c(as.vector(unlist(raster_layers)[grepl('.name',names(unlist(raster_layers)),fixed=T)]))
                    ),
                    options = pickerOptions(
                      dropdownAlignRight = 'auto',
                      maxOptions = 1
                    )
                  )
                )
              )
            )
          ),
          column(
             11,
             mapboxerOutput(ns('map'), height="68vh")
          )
        )
      ),
      tabPanel(
        title = icon("circle-info"),
        ###
        h4("Contextual layers"),
        h6("Conservation Authority Watersheds"),
        h6("Conservation Authority Watersheds: TKN"),
        h6("OWB Primary Watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("OWB Secondary Watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("Tertiary watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("Quaternary watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("Admin 2 Boundaries"),
        tags$ul(
          tags$li(tags$a("US Census Bureau – TIGER/Line Shapefiles", href="https://www.census.gov/cgi-bin/geo/shapefiles/index.php", target="_blank")),
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("ON Census Divisions"),
        tags$ul(
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("ON Census Consolidated Subdivisions"),
        tags$ul(
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("ON Census Subdivisions"),
        tags$ul(
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("US Counties"),
        tags$ul(
          tags$li(tags$a("US Census Bureau – TIGER/Line Shapefiles", href="https://www.census.gov/cgi-bin/geo/shapefiles/index.php", target="_blank"))
        ),
        h6("US Census Tracts"),
        tags$ul(
          tags$li(tags$a("US Census Bureau – TIGER/Line Shapefiles", href="https://www.census.gov/cgi-bin/geo/shapefiles/index.php", target="_blank"))
        ),
        h6("ON Abandoned Mines Information System"),
        tags$ul(
          tags$li(tags$a("Geology Ontario", href="https://www.hub.geologyontario.mines.gov.on.ca/", target="_blank"))
        ),
        h6("Ontario Mineral Extraction Sites"),
        tags$ul(
          tags$li(tags$a("Government of Canada - CanVec", href="https://open.canada.ca/data/en/dataset/8ba2aa2a-7bb9-4448-b4d7-f164409fe056", target="_blank"))
        ),
        h6("Great Lakes Basin Integrated Nutrient Dataset"),
        tags$ul(
          tags$li(tags$a("Great Lakes Basin Integrated Nutrient Dataset (2000-2019)", href="https://open.canada.ca/data/en/dataset/8eecfdf5-4fbc-43ec-a504-7e4ee41572eb", target="_blank"))
        ),
        h6("SPARROW Nitrogen"),
        tags$ul(
          tags$li(tags$a("USGS SPARROW modeling: Estimating nutrient, sediment, and dissolved solids transport ", href="https://www.usgs.gov/mission-areas/water-resources/science/sparrow-modeling-estimating-nutrient-sediment-and-dissolved", target="_blank")),
          tags$li(tags$a("Data description (metadata)", href="https://www.sciencebase.gov/catalog/item/5bae3fe5e4b08583a5d30146", target="_blank")),
          tags$li(tags$a("Harmful Algal Blooms in the Great Lakes", href="https://www.arcgis.com/apps/MapSeries/index.html?appid=d41a2e7273d041d2b496623aa10daa25", target="_blank"))
        ),
        h6("SPARROW Phosphorus"),
        tags$ul(
          tags$li(tags$a("USGS SPARROW modeling: Estimating nutrient, sediment, and dissolved solids transport ", href="https://www.usgs.gov/mission-areas/water-resources/science/sparrow-modeling-estimating-nutrient-sediment-and-dissolved", target="_blank")),
          tags$li(tags$a("Data description (metadata)", href="https://www.sciencebase.gov/catalog/item/5bae3fe5e4b08583a5d30146", target="_blank")),
          tags$li(tags$a("Harmful Algal Blooms in the Great Lakes", href="https://www.arcgis.com/apps/MapSeries/index.html?appid=d41a2e7273d041d2b496623aa10daa25", target="_blank"))
        ),
        h6("ON Wetlands"),
        tags$ul(
          tags$li(tags$a("Ontario Ministry of Natural Resources and Forestry - Wetlands", href="https://geohub.lio.gov.on.ca/datasets/mnrf::wetlands/about", target="_blank"))
        ),
        h6("ON Waterbodies"),
        tags$ul(
          tags$li(tags$a("Ontario Hydro Network (OHN)", href="https://geohub.lio.gov.on.ca/datasets/mnrf::ontario-hydro-network-ohn-waterbody/explore", target="_blank"))
        ),
        h6("ON Watercourses"),
        tags$ul(
          tags$li(tags$a("Ontario Hydro Network (OHN)", href="https://geohub.lio.gov.on.ca/datasets/mnrf::ontario-hydro-network-ohn-watercourse/explore", target="_blank"))
        ),
        h6("US Wetlands"),
        tags$ul(
          tags$li(tags$a("US Fish & Wildlife Service - National Wetlands Inventory", href="https://www.fws.gov/program/national-wetlands-inventory/download-state-wetlands-data", target="_blank"))
        ),
        h6("US Waterbodies"),
        tags$ul(
          tags$li(tags$a("National Hydrography Database (NHD)", href="https://www.epa.gov/waterdata/nhdplus-great-lakes-data-vector-processing-unit-04", target="_blank"))
        ),
        h6("US Watercourses"),
        tags$ul(
          tags$li(tags$a("National Hydrography Database (NHD)", href="https://www.epa.gov/waterdata/nhdplus-great-lakes-data-vector-processing-unit-04", target="_blank"))
        ),
        h6("Bathymetry Contours"),
        tags$ul(
          tags$li(tags$a("NOAA - Great Lakes Bathymetry", href="https://www.ngdc.noaa.gov/mgg/greatlakes/", target="_blank"))
        ),
        h6("ON Geology"),
        tags$ul(
          tags$li(tags$a("Ontario OGSEarth", href="https://www.geologyontario.mndm.gov.on.ca/ogsearth.html", target="_blank"))
        ),
        h6("US Geology"),
        tags$ul(
          tags$li(tags$a("USGS - Geologic maps of US states", href="https://mrdata.usgs.gov/geology/state/", target="_blank"))
        ),
        h6("ON Agriculture"),
        tags$ul(
          tags$li(tags$a("Canada Agricultural Census 2021", href="https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/", target="_blank"))
        ),
        h6("US Agriculture"),
        tags$ul(
          tags$li(tags$a("US Agricultural Census 2017", href="https://www.nass.usda.gov/Publications/AgCensus/2017/Online_Resources/Ag_Census_Web_Maps/Data_download/index.php", target="_blank"))
        ),
        br(),
        ###
        h4("Base layers"),
        h6("Bathymetry"),
        tags$ul(
          tags$li(tags$a("NOAA - Great Lakes Bathymetry", href="https://www.ngdc.noaa.gov/mgg/greatlakes/", target="_blank"))
        ),
        h6("Slope"),
        tags$ul(
          tags$li(tags$a("NASA / USGS - Shuttle Radar Topography Mission (SRTM)", href="https://www.earthdata.nasa.gov/sensors/srtm", target="_blank"))
        ),
        h6("Elevation"),
        tags$ul(
          tags$li(tags$a("NASA / USGS - Shuttle Radar Topography Mission (SRTM)", href="https://www.earthdata.nasa.gov/sensors/srtm", target="_blank"))
        ),
        h6("Terrain (Hillshade)"),
        tags$ul(
          tags$li(tags$a("NASA / USGS - Shuttle Radar Topography Mission (SRTM)", href="https://www.earthdata.nasa.gov/sensors/srtm", target="_blank"))
        ),
        h6("Land Cover"),
        tags$ul(
          tags$li(tags$a("North American Land Cover, 2020 (Landsat, 30m)", href="http://www.cec.org/north-american-environmental-atlas/land-cover-30m-2020/", target="_blank"))
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
    zoom = 4.7,
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
      sources[['mines']],
      id='mines'
    ) %>%
    add_source(
      sources[['nutrient']],
      id='nutrient'
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
    add_layer(vector_layers[['sparrow_phosphorus']][['style']]) %>%
    add_layer(vector_layers[['sparrow_nitrogen']][['style']]) %>%
    add_layer(vector_layers[['glbind_latest_nutrient']][['style']]) %>%
    add_layer(vector_layers[['canvec_extraction_site']][['style']]) %>%
    add_layer(vector_layers[['amis_mine']][['style']]) %>%
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
    add_layer(vector_layers[['ca_watershed_tkn']][['style']]) %>%
    add_layer(vector_layers[['ca_watershed']][['style']]) %>%
    
    # Add mouseover tooltips from layers.R
    add_popups('us_farm_area', mapbox_popup(vector_layers[['us_farm_area']][['tooltip']], event = 'hover')) %>%
    add_popups('on_farm_area', mapbox_popup(vector_layers[['on_farm_area']][['tooltip']], event = 'hover')) %>%
    add_popups('us_geology', mapbox_popup(vector_layers[['us_geology']][['tooltip']], event = 'hover')) %>%
    add_popups('on_geology', mapbox_popup(vector_layers[['on_geology']][['tooltip']], event = 'hover')) %>%
    add_popups('bathymetry_contour', mapbox_popup(vector_layers[['bathymetry_contour']][['tooltip']], event = 'hover')) %>%
    add_popups('us_watercourse', mapbox_popup(vector_layers[['us_watercourse']][['tooltip']], event = 'hover')) %>%
    add_popups('on_watercourse', mapbox_popup(vector_layers[['on_watercourse']][['tooltip']], event = 'hover')) %>%
    add_popups('us_waterbody', mapbox_popup(vector_layers[['us_waterbody']][['tooltip']], event = 'hover')) %>%
    add_popups('on_waterbody', mapbox_popup(vector_layers[['on_waterbody']][['tooltip']], event = 'hover')) %>%
    add_popups('us_wetland', mapbox_popup(vector_layers[['us_wetland']][['tooltip']], event = 'hover')) %>%
    add_popups('on_wetland', mapbox_popup(vector_layers[['on_wetland']][['tooltip']], event = 'hover')) %>%
    add_popups('sparrow_phosphorus', mapbox_popup(vector_layers[['sparrow_phosphorus']][['tooltip']], event = 'hover')) %>%
    add_popups('sparrow_nitrogen', mapbox_popup(vector_layers[['sparrow_nitrogen']][['tooltip']], event = 'hover')) %>%
    add_popups('glbind_latest_nutrient', mapbox_popup(vector_layers[['glbind_latest_nutrient']][['tooltip']], event = 'hover')) %>%
    add_popups('canvec_extraction_site', mapbox_popup(vector_layers[['canvec_extraction_site']][['tooltip']], event = 'hover')) %>%
    add_popups('amis_mine', mapbox_popup(vector_layers[['amis_mine']][['tooltip']], event = 'hover')) %>%
    add_popups('us_county', mapbox_popup(vector_layers[['us_county']][['tooltip']], event = 'hover')) %>%
    add_popups('us_tract', mapbox_popup(vector_layers[['us_tract']][['tooltip']], event = 'hover')) %>%
    add_popups('on_census_subdivision', mapbox_popup(vector_layers[['on_census_subdivision']][['tooltip']], event = 'hover')) %>%
    add_popups('on_census_consolidated_subdivision', mapbox_popup(vector_layers[['on_census_consolidated_subdivision']][['tooltip']], event = 'hover')) %>%
    add_popups('on_census_consolidated_subdivision', mapbox_popup(vector_layers[['on_census_consolidated_subdivision']][['tooltip']], event = 'hover')) %>%
    add_popups('on_census_division', mapbox_popup(vector_layers[['on_census_division']][['tooltip']], event = 'hover')) %>%
    add_popups('adm2', mapbox_popup(vector_layers[['adm2']][['tooltip']], event = 'hover')) %>%
    add_popups('owb_quaternary', mapbox_popup(vector_layers[['owb_quaternary']][['tooltip']], event = 'hover')) %>%
    add_popups('owb_tertiary', mapbox_popup(vector_layers[['owb_tertiary']][['tooltip']], event = 'hover')) %>%
    add_popups('owb_secondary', mapbox_popup(vector_layers[['owb_secondary']][['tooltip']], event = 'hover')) %>%
    add_popups('owb_primary', mapbox_popup(vector_layers[['owb_primary']][['tooltip']], event = 'hover')) %>%
    add_popups('ca_watershed_tkn', mapbox_popup(vector_layers[['ca_watershed_tkn']][['tooltip']], event = 'hover')) %>%
    add_popups('ca_watershed', mapbox_popup(vector_layers[['ca_watershed']][['tooltip']], event = 'hover')) %>%
  
    # Add mouse click popups from layers.R
    add_popups('us_farm_area', vector_layers[['us_farm_area']][['popup']]) %>%
    add_popups('on_farm_area', vector_layers[['on_farm_area']][['popup']]) %>%
    add_popups('us_geology', vector_layers[['us_geology']][['popup']]) %>%
    add_popups('on_geology', vector_layers[['on_geology']][['popup']]) %>%
    add_popups('bathymetry_contour', vector_layers[['bathymetry_contour']][['popup']]) %>%
    add_popups('us_watercourse', vector_layers[['us_watercourse']][['popup']]) %>%
    add_popups('on_watercourse', vector_layers[['on_watercourse']][['popup']]) %>%
    add_popups('us_waterbody', vector_layers[['us_waterbody']][['popup']]) %>%
    add_popups('on_waterbody', vector_layers[['on_waterbody']][['popup']]) %>%
    add_popups('us_wetland', vector_layers[['us_wetland']][['popup']]) %>%
    add_popups('on_wetland', vector_layers[['on_wetland']][['popup']]) %>%
    add_popups('sparrow_phosphorus', vector_layers[['sparrow_phosphorus']][['popup']]) %>%
    add_popups('sparrow_nitrogen', vector_layers[['sparrow_nitrogen']][['popup']]) %>%
    add_popups('glbind_latest_nutrient', vector_layers[['glbind_latest_nutrient']][['popup']]) %>%
    add_popups('canvec_extraction_site', vector_layers[['canvec_extraction_site']][['popup']]) %>%
    add_popups('amis_mine', vector_layers[['amis_mine']][['popup']]) %>%
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
    add_popups('ca_watershed_tkn', vector_layers[['ca_watershed_tkn']][['popup']]) %>%
    add_popups('ca_watershed', vector_layers[['ca_watershed']][['popup']])
  
  output$map <- renderMapboxer({map})
  
  # Set raster layer visibility - choice of one via radio buttons.
  observe({
    sel <- input$rasterSel
    proxy <- mapboxer_proxy(ns("map"), session)
    for (lyr in c(names(raster_layers))) {
      if (lyr %in% sel) {
        proxy %>% set_layout_property(lyr, 'visibility', TRUE) %>% update_mapboxer()
      } else {
        proxy %>% set_layout_property(lyr, 'visibility', FALSE) %>% update_mapboxer()
      }
    }
  })
  
  # Set vector layer visibility - multiple choices via checkboxes.
  observe({
    sel <- input$vectorSel
    proxy <- mapboxer_proxy(ns("map"), session)
    for (lyr in c(names(vector_layers))) {
      if (lyr %in% sel) {
        proxy %>% set_layout_property(lyr, 'visibility', TRUE) %>% update_mapboxer()
      } else {
        proxy %>% set_layout_property(lyr, 'visibility', FALSE) %>% update_mapboxer()
      }
    }
  })
  
  # Add map feature click events for modal tables - only supports TKN at the moment.
  observeEvent(input$map_onclick, {
    e <- input$map_onclick
    lyr <- e$layer_id
    if (lyr %in% names(vector_layers) && 'table' %in% names(vector_layers[[lyr]])) {
      id <- e$props$name
      tbl <- vector_layers[[lyr]][['table']]
      output$tbl <- DT::renderDataTable({
        datatable(
          tbl[tbl$id == id, names(tbl)[names(tbl) != 'id']],
          rownames = FALSE
        )
      })
      showModal(
        modalDialog(
          title = id,
          HTML(
            whisker.render(
              vector_layers[[lyr]][['popup']],
              e$props
            )
          ),
          br(),
          DT::dataTableOutput(ns("tbl")),
          size = "l",
          easyClose = TRUE,
          footer = NULL
        )
      )
    }
  })
  
  #--------------------------------
  #Color selector for vector layers
  #--------------------------------
  
  vector_reactive<-reactiveVal(vector_layers)

  #Vector selection 1
  output$vecCol1<-renderUI({
    req(input$vectorSel[1])

    sel <- input$vectorSel[1]
    nm <- c(as.vector(unlist(vector_reactive())[grepl('.name',names(unlist(vector_reactive())),fixed=T)]))[which(names(vector_reactive()) == sel)]
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"
    if(fillInterpolate) {
      fillType <- vector_reactive()[[sel]]$style$type
      fillLower <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]],
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]]
      )
      fillUpper <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        NA,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]]
      )
      opacity <- vector_reactive()[[sel]]$style$paint[['fill-opacity']]
      
      tagList(
        div(
          style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: space-between; width: 100%; align-items: center;",
          tags$small(tags$strong(nm)),
          actionButton(
            inputId = ns("refreshVec1"),
            label = NULL,
            icon = icon("rotate"),
            style = "background-color: rgba(0,0,0,0)!important;
                                      color: #343a40;
                                      border-style: none;"
          )
        ),
        fluidRow(
          column(
            4,
            colourInput(
              inputId = ns("vecCol1Lower"),
              label = tags$small(ifelse(!is.na(fillUpper), "Fill lower", "Fill")),
              value = fillLower,
              allowTransparent = FALSE,
              showColour = "background",
              width = "100%"
            )
          ),
          column(
            4,
            if(!is.na(fillUpper)){
              colourInput(
                inputId = ns("vecCol1Upper"),
                label = tags$small("Fill upper"),
                value = fillUpper,
                allowTransparent = FALSE,
                showColour = "background",
                width = "100%"
              )
            }
          ),
          column(
            4,
            div(
              style = "margin: 0px 0px; width: 100%;",
              if(!is.null(opacity)){
                sliderInput(
                  inputId = ns("vecOpacity1"), 
                  label = tags$small("Opacity"), 
                  min = 0, 
                  max = 1,
                  step = 0.05,
                  value = opacity,
                  ticks = FALSE,
                  width = "100%"
                )
              }
            )
          )
        ),
        fluidRow(
          
        )
      )
    } else {
      tagList(
        strong(nm),
        br(),
        tags$small(tags$em("Properties not available"))
      )
    }
  })
  
  #Sel 1
  observeEvent(input$refreshVec1, {
    req(input$vectorSel[1])
    sel <- input$vectorSel[1]
    proxy <- mapboxer_proxy(ns("map"), session)
    fillType <- vector_reactive()[[sel]]$style$type
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"
    
    if(fillInterpolate) {

      colLower <- input$vecCol1Lower
      colUpper <- input$vecCol1Upper
      opacity <- input$vecOpacity1
      vector_tmp <- vector_reactive()
      
      if(NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1){
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]] <- colLower
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), colLower) %>%
          set_paint_property(sel, 'fill-opacity', opacity) %>%
          update_mapboxer()
      } else {
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]] <- colLower
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]] <- colUpper
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) %>%
          set_paint_property(sel, 'fill-opacity', vector_reactive()[[sel]]$style$paint[['fill-opacity']]) %>%
          update_mapboxer()
      }
    }
  })
  
  
  #Vector selection 2
  output$vecCol2<-renderUI({
    req(input$vectorSel[1], input$vectorSel[2])

    sel <- input$vectorSel[2]
    nm <- c(as.vector(unlist(vector_reactive())[grepl('.name',names(unlist(vector_reactive())),fixed=T)]))[which(names(vector_reactive()) == sel)]
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"

    if(fillInterpolate) {
      fillType <- vector_reactive()[[sel]]$style$type
      fillLower <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]],
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]]
      )
      fillUpper <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        NA,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]]
      )
      opacity <- vector_reactive()[[sel]]$style$paint[['fill-opacity']]

      tagList(
        div(
          style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: space-between; width: 100%; align-items: center;",
          tags$small(tags$strong(nm)),
          actionButton(
            inputId = ns("refreshVec2"),
            label = NULL,
            icon = icon("rotate"),
            style = "background-color: rgba(0,0,0,0)!important;
                                        color: #343a40;
                                        border-style: none;"
          )
        ),
        fluidRow(
          column(
            4,
            colourInput(
              inputId = ns("vecCol2Lower"),
              label = tags$small(ifelse(!is.na(fillUpper), "Fill lower", "Fill")),
              value = fillLower,
              allowTransparent = FALSE,
              showColour = "background",
              width = "100%"
            )
          ),
          column(
            4,
            if(!is.na(fillUpper)){
              colourInput(
                inputId = ns("vecCol2Upper"),
                label = tags$small("Fill upper"),
                value = fillUpper,
                allowTransparent = FALSE,
                showColour = "background",
                width = "100%"
              )
            }
          ),
          column(
            4,
            div(
              style = "margin: 0px 0px; width: 100%;",
              sliderInput(
                inputId = ns("vecOpacity2"),
                label = tags$small("Opacity"),
                min = 0,
                max = 1,
                value = opacity,
                step = 0.05,
                ticks = FALSE,
                width = "100%"
              )
            )
          )
        )
      )
    } else {
      tagList(
        strong(nm),
        br(),
        tags$small(tags$em("Properties not available"))
      )
    }
  })
  
  #Sel 2
  observeEvent(input$refreshVec2, {
    req(input$vectorSel[1], input$vectorSel[2])
    sel <- input$vectorSel[2]
    proxy <- mapboxer_proxy(ns("map"), session)
    fillType <- vector_reactive()[[sel]]$style$type
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"
    if(fillInterpolate) {
      
      colLower <- input$vecCol2Lower
      colUpper <- input$vecCol2Upper
      opacity <- input$vecOpacity2
      vector_tmp <- vector_reactive()
      
      if(NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1){
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]] <- colLower
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), colLower) %>%
          set_paint_property(sel, 'fill-opacity', opacity) %>%
          update_mapboxer()
      } else {
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]] <- colLower
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]] <- colUpper
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) %>%
          set_paint_property(sel, 'fill-opacity', vector_reactive()[[sel]]$style$paint[['fill-opacity']]) %>%
          update_mapboxer()
      }
    }
  })
  
  #Vector selection 3
  output$vecCol3<-renderUI({
    req(input$vectorSel[1], input$vectorSel[2], input$vectorSel[3])
    
    sel <- input$vectorSel[3]
    nm <- c(as.vector(unlist(vector_reactive())[grepl('.name',names(unlist(vector_reactive())),fixed=T)]))[which(names(vector_reactive()) == sel)]
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"
    
    if(fillInterpolate) {
      fillType <- vector_reactive()[[sel]]$style$type
      fillLower <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]],
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]]
      )
      fillUpper <- ifelse(
        NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1,
        NA,
        vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]]
      )
      opacity <- vector_reactive()[[sel]]$style$paint[['fill-opacity']]
      
      tagList(
        div(
          style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: space-between; width: 100%; align-items: center;",
          tags$small(tags$strong(nm)),
          actionButton(
            inputId = ns("refreshVec3"),
            label = NULL,
            icon = icon("rotate"),
            style = "background-color: rgba(0,0,0,0)!important;
                                        color: #343a40;
                                        border-style: none;"
          )
        ),
        fluidRow(
          column(
            4,
            colourInput(
              inputId = ns("vecCol3Lower"),
              label = tags$small(ifelse(!is.na(fillUpper), "Fill lower", "Fill")),
              value = fillLower,
              allowTransparent = FALSE,
              showColour = "background",
              width = "100%"
            )
          ),
          column(
            4,
            if(!is.na(fillUpper)){
              colourInput(
                inputId = ns("vecCol3Upper"),
                label = tags$small("Fill upper"),
                value = fillUpper,
                allowTransparent = FALSE,
                showColour = "background",
                width = "100%"
              )
            }
          ),
          column(
            4,
            div(
              style = "margin: 0px 0px; width: 100%;",
              sliderInput(
                inputId = ns("vecOpacity3"),
                label = tags$small("Opacity"),
                min = 0,
                max = 1,
                value = opacity,
                step = 0.05,
                ticks = FALSE,
                width = "100%"
              )
            )
          )
        )
      )
    } else {
      tagList(
        strong(nm),
        br(),
        tags$small(tags$em("Properties not available"))
      )
    }
  })
  
  #Sel 3
  observeEvent(input$refreshVec3, {
    req(input$vectorSel[1], input$vectorSel[2], input$vectorSel[3])
    sel <- input$vectorSel[3]
    proxy <- mapboxer_proxy(ns("map"), session)
    fillType <- vector_reactive()[[sel]]$style$type
    fillInterpolate <- vector_reactive()[[sel]]$style$paint[[1]][[1]] != "match"
    if(fillInterpolate) {
      
      colLower <- input$vecCol3Lower
      colUpper <- input$vecCol3Upper
      opacity <- input$vecOpacity3
      vector_tmp <- vector_reactive()
      
      if(NROW(vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) == 1){
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]] <- colLower
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), colLower) %>%
          set_paint_property(sel, 'fill-opacity', opacity) %>%
          update_mapboxer()
      } else {
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[5]] <- colLower
        vector_tmp[[sel]]$style$paint[[paste0(fillType, '-color')]][[7]] <- colUpper
        vector_tmp[[sel]]$style$paint[['fill-opacity']] <- opacity
        vector_reactive(vector_tmp)
        proxy %>%
          set_paint_property(sel, paste0(fillType, '-color'), vector_reactive()[[sel]]$style$paint[[paste0(fillType, '-color')]]) %>%
          set_paint_property(sel, 'fill-opacity', vector_reactive()[[sel]]$style$paint[['fill-opacity']]) %>%
          update_mapboxer()
      }
    }
  })
  
  # Add legends to map.
  observe({
    vectorSel <- input$vectorSel
    react <- vector_reactive()
    runjs(paste0("$('.mapboxgl-ctrl.mapboxer-legend-ctrl').remove();"))
    proxy <- mapboxer_proxy(ns("map"), session)
    
    # Add vector layers in order selected.
    for (i in vectorSel) {
      fillInterpolate <- vector_reactive()[[i]]$style$paint[[1]][[1]] != "match"
      if (fillInterpolate) {
        fillType <- vector_reactive()[[i]]$style$type
        if (NROW(vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]]) == 1) {
          cols <- c(vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]])
          labels <- ''
        } else {
          cols <- c(vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]][[7]], vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]][[5]])
          labels <- c(
            vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]][[6]],
            vector_reactive()[[i]]$style$paint[[paste0(fillType, '-color')]][[4]]
          )
        }
      } else {
        labels <- unlist(vector_layers[['on_geology']]$style$paint$`fill-color`[c(TRUE, FALSE)])[-c(1)]
        labels <- labels[-c(length(labels))]
        cols <- unlist(vector_layers[['on_geology']]$style$paint$`fill-color`[c(FALSE, TRUE)][-c(1)])
      }
      proxy %>%
        add_legend_control(
          cols,
          labels,
          title = paste0('<b>', vector_reactive()[[i]][['name']], '</b>'),
          pos = "top-left"
        ) %>% update_mapboxer()
    }
    
    # Add raster layer if present and a legend exists in layers.R.
    rasterSel <- input$rasterSel
    if (!is.null(rasterSel) && 'legend' %in% names(raster_layers[[rasterSel]])) {
      cols <- as.vector(raster_layers[[rasterSel]][['legend']])
      labels <- names(raster_layers[[rasterSel]][['legend']])
      proxy %>%
        add_legend_control(
          cols,
          labels,
          title = paste0('<b>', raster_layers[[rasterSel]][['name']], '</b>'),
          pos = "top-left"
        ) %>% update_mapboxer()
    }
  })
}