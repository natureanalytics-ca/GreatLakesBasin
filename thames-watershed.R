# Read GIS layers.
watershedBounds <- read_sf('./data/thames_watershed_ofat_watershed.geojson')
owbQuaternary <- read_sf('./data/thames_watershed_owb_quaternary.geojson')
owbTertiary <- read_sf('./data/thames_watershed_owb_tertiary.geojson')
placeLowZoom <- read_sf('./data/thames_watershed_label_low_zoom.geojson')
placeHighZoom <- read_sf('./data/thames_watershed_label_high_zoom.geojson')
hydatStation <- read_sf('./data/thames_watershed_hydat_station.geojson')
glbindStation <- read_sf('./data/thames_watershed_glbind_station.geojson')
censusDivision <- read_sf('./data/thames_watershed_census_division.geojson')
censusSubdivision <- read_sf('./data/thames_watershed_census_subdivision.geojson')
upperThamesStations <- read_sf('./data/upper_thames_stations.geojson')
geology <- read_sf('./data/thames_watershed_geology.geojson')
sparrow <- read_sf('./data/thames_watershed_sparrow.geojson')
soil <- read_sf('./data/thames_watershed_soil.geojson')

# Read and process feature layer attributes.
hydatFlow <- read.csv('./data/thames_watershed_hydat_monthly_flow.csv')
hydatFlow <- hydatFlow[order(hydatFlow$year, hydatFlow$month),]
hydatLevel <- read.csv('./data/thames_watershed_hydat_monthly_level.csv')
hydatLevel <- hydatLevel[order(hydatLevel$year, hydatLevel$month),]
glbindNutrients <- read.csv('./data/thames_watershed_glbind_ts.csv')
glbindUnits <- read.csv('./data/thames_watershed_glbind_unit.csv')
glbindNutrients <- merge(glbindNutrients, glbindUnits)
glbindNutrients <- glbindNutrients[order(glbindNutrients$nutrient, glbindNutrients$datetime),]
upperThamesTemperature <- read.csv('./data/upper_thames_ts.csv')
upperThamesStations <- upperThamesStations[upperThamesStations$station_no %in% upperThamesTemperature$station_no,]

# Define UI for tab.
twUI <- function(id) {
  ns <- NS(id)
  
  autoWaiter(ns("thamesMap"))
  
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
          "Thames River Watershed"
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
              h6("Thames River Watershed"),
              tags$small("Test.")
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
                  icon = icon("layer-group"),
                  tooltip = tooltipOptions(title = "Data layers"),
                  pickerInput(
                    ns('featureLayers'),
                    'Data layers (select multiple)',
                    multiple = TRUE,
                    choices = setNames(
                      c(
                        'hydatStation',
                        'glbindStation',
                        'upperThamesStation',
                        'sparrow',
                        'soil',
                        'geology'
                      ),
                      c(
                        'HYDAT Flow and Level Stations',
                        'GLBIND Nutrient Stations',
                        'Upper Thames Water Temperature Stations',
                        'SPARROW Nutrient Catchments',
                        'Soil complex',
                        'Bedrock Geology'
                      )
                    ),
                    choicesOpt = list(
                      content = c(
                        "<div> <i class='fas fa-circle-dot' style = 'color: gold;'></i> HYDAT Flow and Level Stations </div>",
                        "<div> <i class='fas fa-circle-dot' style = 'color: firebrick;'></i> GLBIND Nutrient Stations </div>",
                        "<div> <i class='fas fa-circle-dot' style = 'color: violet;'></i> Upper Thames Water Temperature Stations </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: purple;'></i> SPARROW Nutrient Catchments </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: brown;'></i> Soil complex </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: tomato;'></i> 'Bedrock Geology' </div>"
                      )
                    ),
                    options = pickerOptions(
                      dropdownAlignRight = 'auto'
                    )
                  ),
                ),
                shinyWidgets::dropdown(
                  style = "simple",
                  status = "default",
                  size = "lg",
                  width = "400px",
                  icon = icon("road"),
                  tooltip = tooltipOptions(title = "Contextual layers"),
                  pickerInput(
                    ns('contextualLayers'),
                    'Contextual layers (select multiple)',
                    multiple = TRUE,
                    selected = 'place',
                    choices = setNames(
                      c(
                        'place',
                        'censusSubdivision',
                        'censusDivision',
                        'owbQuaternary',
                        'owbTertiary',
                        'watershedBounds'
                      ),
                      c(
                        'Places',
                        'Census subdivisions',
                        'Census divisions',
                        'Quaternary watersheds',
                        'Tertiary watersheds',
                        'Watershed bounds'
                      )
                    ),
                    choicesOpt = list(
                      content = c(
                        "<div> <i class='fas fa-square' style = 'color: black;'></i> Places </div>",
                        "<div> <i class='fas fa-square' style = 'color: #A9A9A9;'></i> Census subdivisions </div>",
                        "<div> <i class='fas fa-square' style = 'color: #343a40;'></i> Census divisions </div>",
                        "<div> <i class='fas fa-square' style = 'color: #191970;'></i> Quaternary watersheds </div>",
                        "<div> <i class='fas fa-square' style = 'color: #0047AB;'></i> Tertiary watersheds </div>",
                        "<div> <i class='fas fa-square' style = 'color: black;'></i> Watershed bounds </div>"
                      )
                    ),
                    options = pickerOptions(
                      dropdownAlignRight = 'auto'
                    )
                  ),
                  br(),
                  prettySwitch(
                    ns('labels'),
                    'Labels',
                    value = TRUE
                  )
                ),
                shinyWidgets::dropdown(
                  style = "simple",
                  status = "default",
                  size = "lg",
                  width = "400px",
                  icon = icon("map"),
                  tooltip = tooltipOptions(title = "Base layers"),
                  pickerInput(
                    ns('baseSel'),
                    'Base layers (select one)',
                    multiple = TRUE,
                    selected = 'Cartographic',
                    choices = setNames(
                      c('Cartographic', 'Terrain', 'Landcover'),
                      c('Cartographic', 'Terrain', 'Landcover')
                     
                    ),
                    options = pickerOptions(
                      maxOptions = 1,
                      dropdownAlignRight = 'auto'
                    )
                  )
                )
              )
            )
          ),
          column(
            11,
            
            leafletOutput(ns('thamesMap')),
            shinyjs::hidden(
              div(
                id = ns('loading'), 
                align = "center",
                style = "position: absolute; top: 100px; left: 0%; width: 100%;",
                addSpinner(
                  div(), spin = "circle", color = "#c20430"
                ),
                br(),
                "Rendering takes 30 seconds ..."
              )
            )
          )
        )
      ),
      tabPanel(
        title = icon("circle-info")
      ),
      tabPanel(
        title = icon("chart-simple")
      )
    )
  )
}

# Define server logic
twServer <- function(input, output, session) {
  ns <- session$ns

  # Generate map.
  output$thamesMap <- renderLeaflet({
    shinyjs::showElement(id = ns("loading"), asis=TRUE)
    leaflet(
      options = leafletOptions(
        minZoom = 8, maxZoom = 14, zoomControl = FALSE
      ) 
    ) %>%
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'bottomleft' }).addTo(this)
    }") %>%
    setView(-80.7, 42.8, 8) %>%
    
      #-----------
      #Base layers
      #-----------
      addTiles(
        paste0(styleURL, 'cartographic/{z}/{x}/{y}.png'),
        group = 'Cartographic'
      ) %>%
      addTiles(
        paste0(styleURL, 'terrain/{z}/{x}/{y}.png'),
        group = 'Terrain'
      ) %>%
      hideGroup("Terrain") %>%
      addTiles(
        paste0(styleURL, 'land-cover/{z}/{x}/{y}.png'),
        group = 'Landcover'
      ) %>%
      hideGroup("Landcover") %>%
      
      #-----------------
      #Contextual layers
      #-----------------
      addMapPane("placeLowZoom_pane", zIndex = 460) %>%
      addMapPane("placeHighZoom_pane", zIndex = 460) %>%
      addMapPane("placeLowZoomLabels_pane", zIndex = 460) %>%
      addMapPane("placeHighZoomLabels_pane", zIndex = 460) %>%
      addMapPane("censusSubdivisionLabels_pane", zIndex = 455) %>%
      addMapPane("censusSubdivision_pane", zIndex = 450) %>%
      addMapPane("censusDivisionLabels_pane", zIndex = 445) %>%
      addMapPane("censusDivision_pane", zIndex = 440) %>%
      addMapPane("owbQuaternaryLabels_pane", zIndex = 435) %>%
      addMapPane("owbQuaternary_pane", zIndex = 430) %>%
      addMapPane("owbTertiaryLabels_pane", zIndex = 425) %>%
      addMapPane("owbTertiary_pane", zIndex = 420) %>%
      addMapPane("watershedBounds_pane", zIndex = 410) %>%
      
      addPolygons(
        data = censusSubdivision, group = 'censusSubdivision', options = pathOptions(pane = "censusSubdivision_pane"), weight = 1, color = "#A9A9A9", fill = FALSE, opacity = 1
      ) %>%
      hideGroup("censusSubdivision") %>%
      addPolygons(
        data = censusDivision, group = 'censusDivision', options = pathOptions(pane = "censusDivision_pane"), weight = 2, color = "#343a40", fill = FALSE, opacity = 1
      ) %>%
      hideGroup("censusDivision") %>%
      addPolygons(
        data = owbQuaternary, group = 'owbQuaternary', options = pathOptions(pane = "owbQuaternary_pane"), weight = 1, color = "#191970", fill = FALSE, opacity = 1
      ) %>%
      hideGroup("owbQuaternary") %>%
      addPolygons(
        data = watershedBounds, group = 'watershedBounds', options = pathOptions(pane = "watershedBounds_pane"), weight = 2, color = "black", fill = FALSE, opacity = 1
      ) %>%
      hideGroup("watershedBounds") %>%
      addPolygons(
        data = owbTertiary, group = 'owbTertiary', options = pathOptions(pane = "owbTertiary_pane"), weight = 2, color = "#0047AB", fill = FALSE, opacity = 1
      ) %>%
      hideGroup("owbTertiary") %>%
      addCircleMarkers(
        data = placeLowZoom,
        group = 'placeLowZoom',
        options = pathOptions(pane = "placeLowZoom_pane"),
        color = 'black',
        stroke = FALSE,
        radius = 3,
        fillOpacity = 1
      ) %>%
      hideGroup("placeLowZoom") %>%
      addCircleMarkers(
        data = placeHighZoom,
        group = 'placeHighZoom',
        options = pathOptions(pane = "placeHighZoom_pane"),
        color = 'black',
        stroke = FALSE,
        radius = 3,
        fillOpacity = 1
      ) %>%
      hideGroup("placeHighZoom") %>%
      
      addLabelOnlyMarkers(
        data = st_point_on_surface(owbQuaternary),
        group = 'owbQuaternaryLabels',
        options = pathOptions(pane = "owbQuaternaryLabels_pane"),
        label = owbQuaternary$watershed_name,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          style = list(
            "color" = "#191970",
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("owbQuaternaryLabels") %>%
      addLabelOnlyMarkers(
        data = st_point_on_surface(owbTertiary),
        group = 'owbTertiaryLabels',
        options = pathOptions(pane = "owbTertiaryLabels_pane"),
        label = owbTertiary$watershed_name,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          style = list(
            "color" = "#0047AB",
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("owbTertiaryLabels") %>%
      addLabelOnlyMarkers(
        data = st_point_on_surface(censusDivision),
        group = 'censusDivisionLabels',
        options = pathOptions(pane = "censusDivisionLabels_pane"),
        label = censusDivision$name,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          style = list(
            "color" = "#343a40",
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("censusDivisionLabels") %>%
      addLabelOnlyMarkers(
        data = st_point_on_surface(censusSubdivision),
        group = 'censusSubdivisionLabels',
        options = pathOptions(pane = "censusSubdivisionLabels_pane"),
        label = censusSubdivision$name,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          style = list(
            "color" = "#A9A9A9",
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("censusSubdivisionLabels") %>%
      addLabelOnlyMarkers(
        data = placeLowZoom,
        group = 'placeLowZoomLabels',
        options = pathOptions(pane = "placeLowZoomLabels_pane"),
        label = placeLowZoom$name_en,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          direction = 'top',
          offset = list(0, 10),
          style = list(
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("placeLowZoomLabels") %>%
      addLabelOnlyMarkers(
        data = placeHighZoom,
        group = 'placeHighZoomLabels',
        options = pathOptions(pane = "placeHighZoomLabels_pane"),
        label = placeHighZoom$name_en,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = TRUE,
          direction = 'top',
          offset = list(0, 10),
          style = list(
            "text-shadow" = "-1px -1px 2px white, 1px -1px 2px white, -1px 1px 2px white, 1px 1px 2px white",
            "font-size" = "8px"
          )
        )
      ) %>%
      hideGroup("placeHighZoomLabels") %>%
      
      #--------------
      #Feature layers
      #--------------
    
      addPolygons(
        layerId = c(1: nrow(geology)),
        data = geology,
        group = 'geology',
        weight = 1,
        color = "tomato",
        fill = TRUE,
        opacity = 0.5,
        label = lapply(geology$rocktype_p , HTML)
      ) %>%
      hideGroup("geology") %>%
      addPolygons(
        layerId = c(1: nrow(soil)),
        data = soil,
        group = 'soil',
        weight = 1,
        color = "brown",
        fill = TRUE,
        opacity = 0.5,
        label = lapply(soil$mapunit, HTML)
      ) %>%
      hideGroup("soil") %>%
      addPolygons(
        layerId = c(1: nrow(sparrow)),
        data = sparrow,
        group = 'sparrow',
        weight = 1,
        color = "purple",
        fill = TRUE,
        opacity = 0.5,
        label = lapply(sparrow$hu8_catchment, HTML)
      ) %>%
      hideGroup("sparrow") %>%
      addCircleMarkers(
        layerId = glbindStation$station,
        data = glbindStation,
        group = 'glbindStation',
        color = 'firebrick',
        radius = 5,
        opacity = 0.8,
        fillOpacity = 0.5,
        label = lapply(glbindStation$station, HTML)
      ) %>%
      hideGroup("glbindStation") %>%
      addCircleMarkers(
        layerId = hydatStation$station_name,
        data = hydatStation,
        group = 'hydatStation',
        color = 'gold',
        radius = 5,
        opacity = 0.8,
        fillOpacity = 0.5,
        label = lapply(hydatStation$station_name, HTML)
      ) %>%
      hideGroup("hydatStation") %>%
      addCircleMarkers(
        layerId = upperThamesStations$station_no,
        data = upperThamesStations,
        group = 'upperThamesStation',
        color = 'violet',
        radius = 5,
        opacity = 0.8,
        fillOpacity = 0.5,
        label = lapply(upperThamesStations$station_no, HTML)
      ) %>%
      hideGroup("upperThamesStation") 
  })
  
  #Make-shift loading screen - horrible solution, but fix later
  observe({
    input$thamesMap_zoom
    shinyjs::hideElement(id = ns("loading"), asis=TRUE)
  })

  #Base layer - update
  observe({
    leafletProxy("thamesMap") %>%
      hideGroup("Cartographic") %>%
      hideGroup("Terrain") %>%
      hideGroup("Landcover") %>%
      showGroup(input$baseSel)
  })   

  # Set vector layers.
  observe({
    contextualSel <- input$contextualLayers
    featureSel <- input$featureLayers
    labels <- input$labels
    proxy <- leafletProxy(ns("thamesMap"))
    z <- isolate(req(input$thamesMap_zoom))
    for (lyr in c(
      'geology',
      'soil',
      'sparrow',
      'owbQuaternary',
      'owbTertiary',
      'censusSubdivision',
      'censusDivision',
      'watershedBounds',
      'upperThamesStation',
      'glbindStation',
      'hydatStation'
    )) {
      proxy %>% hideGroup(lyr)
      proxy %>% hideGroup(paste0(lyr, 'Labels'))
      visible <- lyr %in% contextualSel ||  lyr %in% featureSel
      if (visible) {
        proxy %>% showGroup(lyr)
        if (labels & lyr %in% c(
          'owbQuaternary',
          'owbTertiary',
          'censusSubdivision',
          'censusDivision'
        )) {
          proxy %>% showGroup(paste0(lyr, 'Labels'))
        }
      }
    }

    # Add places on top.
    if (z < 12) {
      lyr <- 'placeLowZoom'
    } else {
      lyr <- 'placeHighZoom'
    }
    proxy %>% hideGroup(lyr)
    proxy %>% hideGroup(paste0(lyr, 'Labels'))
    if ('place' %in% contextualSel) {
      proxy %>% showGroup(lyr)
      if (labels) {
        lyr <- paste0(lyr, 'Labels')
        proxy %>% showGroup(lyr)
      }
    }
  })

  # Set places by zoom level.
  observe({
    z <- req(input$thamesMap_zoom)
    sel <- isolate(input$contextualLayers)
    labels <- isolate(input$labels)
    proxy <- leafletProxy(ns("thamesMap"))
    if ('place' %in% sel) {
      proxy %>% hideGroup('placeLowZoom')
      proxy %>% hideGroup('placeLowZoomLabels')
      proxy %>% hideGroup('placeHighZoom')
      proxy %>% hideGroup('placeHighZoomLabels')
      if (z < 12) {
        lyr <- 'placeLowZoom'
      } else {
        lyr <- 'placeHighZoom'
      }
      proxy %>% showGroup(lyr)
      if (labels) {
        lyr <- paste0(lyr, 'Labels')
        proxy %>% showGroup(lyr)
      }
    }
  })

  # Set legends.
  observe({
    lyrs <- req(input$thamesMap_groups)
    proxy <- leafletProxy(ns("thamesMap"))
    
    # Add basemap.
    colors <- NULL
    labels <- NULL
    if ('Cartographic' %in% lyrs) {
      title <- 'Land use'
      colors = c(
        rgb(71, 222, 224, 255, maxColorValue = 255),
        rgb(126, 167, 220, 255, maxColorValue = 255),
        "#cd9f72",
        "#adffce",
        "#34ebb4",
        "#04e07a",
        "#35f2a7",
        rgb(177, 177, 177, 255, maxColorValue = 255),
        rgb(162, 162, 162, 255, maxColorValue = 255),
        rgb(128, 128, 128, 255, maxColorValue = 255),
        rgb(244, 255, 196, 255, maxColorValue = 255)
      )
      labels <- c(
        "Wetland",
        "Water",
        "Shrubland",
        "Wetland Treed",
        "Coniferous Forest",
        "Deciduous Forest",
        "Mixed Forest",
        "Road",
        "Trail",
        "Railway",
        "Other"
      )
    } 
    
    if ('Terrain' %in% lyrs) {
      title <- 'Elevation (m)'
      colors <- rev(c(
        rgb(2, 124, 30, 255, maxColorValue = 255),
        rgb(70, 137, 40, 255, maxColorValue = 255),
        rgb(105, 149, 54, 255, maxColorValue = 255),
        rgb(134, 160, 71, 255, maxColorValue = 255),
        rgb(159, 170, 90, 255, maxColorValue = 255),
        rgb(181, 180, 109, 255, maxColorValue = 255),
        rgb(201, 189, 130, 255, maxColorValue = 255),
        rgb(218, 197, 150, 255, maxColorValue = 255),
        rgb(231, 205, 170, 255, maxColorValue = 255),
        rgb(241, 213, 191, 255, maxColorValue = 255),
        rgb(242, 218, 206, 255, maxColorValue = 255),
        rgb(226, 226, 226, 255, maxColorValue = 255)
      ))
      labels <- c("421 m", "", "", "", "", "", "", "", "", "", "", "172 m")
    } 
    
    if ('Landcover' %in% lyrs) {
      title <- 'Land class'
      colors <-  as.vector(raster_layers[['land_cover']][['legend']])
      labels <- names(raster_layers[['land_cover']][['legend']])
    } 
    
    proxy %>%
      removeControl(layerId = "basemap")
    if(!is.null(colors)){
      proxy %>%
        addLegend(
          "topright",
          layerId = "basemap",
          title = paste(strong("Base layer"), tags$br(), tags$br(), title),
          colors = colors,
          labels = labels
        )
    }
    
    # # Add other layers, see: https://stackoverflow.com/questions/52812238/custom-legend-with-r-leaflet-circles-and-squares-in-same-plot-legends
    # #colors <- c("#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid black; border-radius:0%;")
    # #labels <- c("Thames River Watershed")
    # colors <- NULL
    # labels <- NULL
    # 
    # if (any(c('placeHighZoom', 'placeHighZoomLabels', 'placeLowZoom', 'placeLowZoomLabels') %in% lyrs)) {
    #   colors <- c(colors, "black; width:10px; height:10px; margin-top: 4px; border:1px solid black; border-radius:50%;")
    #   labels <- c(labels, 'Places')
    # }
    # if ('censusSubdivision' %in% lyrs) {
    #   colors <- c(colors, "#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid #A9A9A9; border-radius:0%;")
    #   labels <- c(labels, 'Census Subdivisions')
    # }
    # if ('censusDivision' %in% lyrs) {
    #   colors <- c(colors, "#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid #343a40; border-radius:0%;")
    #   labels <- c(labels, 'Census Divisions')
    # }
    # if ('owbQuaternary' %in% lyrs) {
    #   colors <- c(colors, "#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid #191970; border-radius:0%;")
    #   labels <- c(labels, 'Quaternary Watersheds')
    # }
    # if ('owbTertiary' %in% lyrs) {
    #   colors <- c(colors, "#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid #0047AB; border-radius:0%;")
    #   labels <- c(labels, 'Tertiary Watersheds')
    # }
    # 
    # if ('watershedBounds' %in% lyrs) {
    #   colors <- c(colors, "#FAFAFA; width:10px; height:10px; margin-top: 4px; border:2px solid black; border-radius:0%;")
    #   labels <- c(labels, "Watershed bounds")
    # }
    # 
    # labels <- paste0(
    #   "<div style='display: inline-block; height: 10px; margin-top: 4px; line-height: 10px; vertical-align: top;'>",
    #   labels,
    #   "</div>"
    # )
    # 
    # proxy %>%
    #   removeControl(layerId = "layers")
    # if(!is.null(colors)){
    #   proxy %>%
    #     addLegend(
    #       "topright",
    #       colors = colors,
    #       title = paste(strong("Contextual layer"), tags$br(), tags$br()),
    #       layerId = "layers",
    #       labels = labels,
    #       opacity = 1
    #     )
    # }
    
    # if ('hydatStation' %in% lyrs) {
    #   colors <- c(colors, "yellow; width:10px; height:10px; margin-top: 4px; border:2px solid gold; border-radius:50%;")
    #   labels <- c(labels, 'HYDAT Flow and Level Stations')
    # }
    # if ('glbindStation' %in% lyrs) {
    #   colors <- c(colors, "red; width:10px; height:10px; margin-top: 4px; border:2px solid firebrick; border-radius:50%;")
    #   labels <- c(labels, 'GLBIND Nutrient Stations')
    # }
    # if ('upperThamesStation' %in% lyrs) {
    #   colors <- c(colors, "#d6b4fc; width:10px; height:10px; margin-top: 4px; border:2px solid violet; border-radius:50%;")
    #   labels <- c(labels, 'Upper Thames Water Temperature Stations')
    # }
    # if ('sparrow' %in% lyrs) {
    #   colors <- c(colors, "violet; width:10px; height:10px; margin-top: 4px; border:1px solid purple; border-radius:0%;")
    #   labels <- c(labels, 'SPARROW Nutrient Catchments')
    # }
    # if ('soil' %in% lyrs) {
    #   colors <- c(colors, "#C4A484; width:10px; height:10px; margin-top: 4px; border:1px solid brown; border-radius:0%;")
    #   labels <- c(labels, 'Soil Complex')
    # }
    # if ('geology' %in% lyrs) {
    #   colors <- c(colors, "#FFCCCB; width:10px; height:10px; margin-top: 4px; border:1px solid darkred; border-radius:0%;")
    #   labels <- c(labels, 'Bedrock Geology')
    # }
  })

  # Add map feature click events for modal tables.
  observeEvent(input$thamesMap_marker_click, {
    id <- input$thamesMap_marker_click$id[[1]]
    group <- input$thamesMap_marker_click$group[[1]]
    if (group %in% c('hydatStation', 'glbindStation', 'upperThamesStation')) {
      if (group == 'upperThamesStation') {
        output$temperatureTbl <- DT::renderDataTable({
          datatable(
            upperThamesTemperature[upperThamesTemperature$station_no == id, names(upperThamesTemperature)[names(upperThamesTemperature) != 'station_no']],
            rownames = FALSE
          )
        })
        showModal(
          modalDialog(
            title = id,
            br(),
            p('Daily Temperature'),
            DT::dataTableOutput(ns("temperatureTbl")),
            size = "l",
            easyClose = TRUE,
            footer = NULL
          )
        )
      } else if (group == 'hydatStation') {
        output$hydatFlowTbl <- DT::renderDataTable({
          datatable(
            hydatFlow[hydatFlow$station_number == id, names(hydatFlow)[names(hydatFlow) != 'station_number']],
            rownames = FALSE
          )
        })
        output$hydatLevelTbl <- DT::renderDataTable({
          datatable(
            hydatLevel[hydatLevel$station_number == id, names(hydatLevel)[names(hydatLevel) != 'station_number']],
            rownames = FALSE
          )
        })
        showModal(
          modalDialog(
            title = id,
            br(),
            p('Monthly Flow'),
            DT::dataTableOutput(ns("hydatLevelTbl")),
            br(),
            p('Monthly Level'),
            DT::dataTableOutput(ns("hydatLevelTbl")),
            size = "l",
            easyClose = TRUE,
            footer = NULL
          )
        )
      } else if (group == 'glbindStation') {
        output$glbindNTbl <- DT::renderDataTable({
          datatable(
            glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'N', names(glbindNutrients)[!names(glbindNutrients) %in% c('station', 'generalized')]],
            rownames = FALSE
          )
        })
        output$glbindPTbl <- DT::renderDataTable({
          datatable(
            glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'P', names(glbindNutrients)[!names(glbindNutrients) %in% c('station', 'generalized')]],
            rownames = FALSE
          )
        })
        showModal(
          modalDialog(
            title = id,
            br(),
            p('Nutrient: N'),
            DT::dataTableOutput(ns("glbindNTbl")),
            br(),
            p('Nutrient: P'),
            DT::dataTableOutput(ns("glbindPTbl")),
            size = "l",
            easyClose = TRUE,
            footer = NULL
          )
        )
      }
    }
  })
  observeEvent(input$thamesMap_shape_click, {
    id <- input$thamesMap_shape_click$id[[1]]
    group <- input$thamesMap_shape_click$group[[1]]
    if (group %in% c('geology', 'soil', 'sparrow')) {
      if (group == 'geology') {
        df <- geology
        title <- 'Bedrock Geology'
      } else if (group == 'soil') {
        df <- soil
        title <- 'Soil Complex'
      } else if (group == 'sparrow') {
        df <- sparrow
        title <- 'SPARROW Nutrients'
      }
      df <- t(st_drop_geometry(df[id,]))
      output$dataTbl <- DT::renderDataTable({
        datatable(
          df,
          colnames = NULL,
          options = list(
            dom = 't',
            ordering = FALSE,
            selection = 'none',
            pageLength = nrow(df)
          )
        )
      })
      showModal(
        modalDialog(
          title = title,
          DT::dataTableOutput(ns("dataTbl")),
          size = "l",
          easyClose = TRUE,
          footer = NULL
        )
      )
    }
  })
}