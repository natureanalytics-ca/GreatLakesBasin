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
              tags$small("Prototype for gathering, processing, and simple visualization of spatial data for Thames River Watershed.")
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
                        "<div> <i class='fas fa-circle-dot' style = 'color: gold;'></i> HYDAT flow and level stations </div>",
                        "<div> <i class='fas fa-circle-dot' style = 'color: firebrick;'></i> GLBIND nutrient stations </div>",
                        "<div> <i class='fas fa-circle-dot' style = 'color: violet;'></i> Upper Thames water temperature stations </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: purple;'></i> SPARROW Nutrient Catchments </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: brown;'></i> Soil complex </div>",
                        "<div> <i class='fas fa-square-full' style = 'color: tomato;'></i> Bedrock geology </div>"
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
                      c('Cartographic', 'Terrain', 'Land cover')
                     
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
        title = icon("circle-info"),
        ###
        h4("Data layers"),
        h6("HYDAT flow and level stations"),
        tags$ul(
          tags$li(tags$a("National Water Data Archive: HYDAT", href="https://www.canada.ca/en/environment-climate-change/services/water-overview/quantity/monitoring/survey/data-products-services/national-archive-hydat.html", target="_blank")),
          tags$li(tags$a("Data description (metadata)", href="https://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/HYDAT_Definition_EN.pdf", target="_blank"))
        ),
        h6("GLBIND nutrient stations"),
        h6("Upper Thames water temperature stations"),
        h6("SPARROW nutrient catchments"),
        tags$ul(
          tags$li(tags$a("USGS SPARROW modeling: Estimating nutrient, sediment, and dissolved solids transport ", href="https://www.usgs.gov/mission-areas/water-resources/science/sparrow-modeling-estimating-nutrient-sediment-and-dissolved", target="_blank")),
          tags$li(tags$a("Data description (metadata)", href="https://www.sciencebase.gov/catalog/item/5bae3fe5e4b08583a5d30146", target="_blank")),
          tags$li(tags$a("Harmful Algal Blooms in the Great Lakes", href="https://www.arcgis.com/apps/MapSeries/index.html?appid=d41a2e7273d041d2b496623aa10daa25", target="_blank"))
        ),
        h6("Soil complex"),
        tags$ul(
          tags$li(tags$a("Ontario Soil Survey Complex", href="https://geohub.lio.gov.on.ca/datasets/ontarioca11::soil-survey-complex/about", target="_blank")),
          tags$li(tags$a("Data description (metadata)", href="https://www.publicdocs.mnr.gov.on.ca/mirb/Soil%20Survey%20Complex%20-%20Data%20Description.pdf", target="_blank"))
        ),
        h6("Bedrock geology"),
        tags$ul(
          tags$li(tags$a("Ontario OGSEarth", href="https://www.geologyontario.mndm.gov.on.ca/ogsearth.html", target="_blank")),
        ),
        br(),
        ###
        h4("Contextual layers"),
        h6("Places"),
        h6("Census subdivisions"),
        tags$ul(
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("Census divisions"),
        tags$ul(
          tags$li(tags$a("Canada 2021 Census – Boundary files", href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21", target="_blank"))
        ),
        h6("Quaternary watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("Tertiary watersheds"),
        tags$ul(
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        h6("Watershed bounds"),
        tags$ul(
          tags$li("Tertiary watersheds of the Thames River (combined Lower Thames and Upper Thames)"),
          tags$li(tags$a("Ontario Watershed Boundaries (OWB)", href="https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about", target="_blank"))
        ),
        br(),
        ###
        h4("Base layers"),
        h6("Cartographic"),
        h6("Terrain"),
        h6("Landcover"),
        tags$ul(
          tags$li(tags$a("North American Land Cover, 2020 (Landsat, 30m)", href="http://www.cec.org/north-american-environmental-atlas/land-cover-30m-2020/", target="_blank"))
        )
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
        label = lapply(glbindStation$location, HTML)
      ) %>%
      hideGroup("glbindStation") %>%
      addCircleMarkers(
        layerId = hydatStation$station_number,
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
        label = lapply(upperThamesStations$station_name, HTML)
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
          "bottomright",
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
            rownames = FALSE,
            options = list(pageLength = 5, lengthMenu = c(5, 10, 25, 50))
          )
        })
        output$temperaturePlot <- renderPlot({
          dt <- data.frame(upperThamesTemperature[upperThamesTemperature$station_no == id, ])
          dt <- cbind(day = as.Date(dt$timestamp), dt)
          dt <- dt %>%
            group_by(day) %>%
            summarize(mean = mean(value), n = n())
          
          ggplot(data = dt, aes(x = day, y = mean)) +
            geom_line(color="#ffc500", linetype="solid",  size=1.5, lineend = "round") +
            labs(
              x = "Date",
              y = "Daily mean temperature (deg. C)"
            ) + 
            theme(
              panel.background = element_rect(fill='transparent'), #transparent panel bg
              plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
              panel.grid.major = element_blank(), #remove major gridlines
              panel.grid.minor = element_blank(), #remove minor gridlines
              axis.line = element_line(colour = "black"),
              strip.text.x = element_text(size=10),
              strip.text.y = element_text(size=10, vjust = 1),
              axis.text.x = element_text( size = 10),
              axis.text.y = element_text( size = 10),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              plot.title = element_text(size=10, face = "bold")
            ) +
            scale_x_date(date_labels =  "%b %Y")
        }, res= 96, bg='transparent')
        
        showModal(
          modalDialog(
            title = id,
            tabBox(
              title = strong('Daily water temperature'),
              width = 12,
              collapsible = FALSE,
              tabPanel(
                title = icon("chart-line"),
                plotOutput(ns("temperaturePlot"))
              ),
              tabPanel(
                title = icon("database"),
                DT::dataTableOutput(ns("temperatureTbl"))
              )
            ),
            size = "l",
            easyClose = TRUE,
            footer = NULL
          )
        )
      } else if (group == 'hydatStation') {
        output$hydatFlowTbl <- DT::renderDataTable({
          datatable(
            hydatFlow[hydatFlow$station_number == id, names(hydatFlow)[names(hydatFlow) != 'station_number']],
            rownames = FALSE,
            options = list(pageLength = 5, lengthMenu = c(5, 10, 25, 50))
          )
        })
        output$hydatLevelTbl <- DT::renderDataTable({
          datatable(
            hydatLevel[hydatLevel$station_number == id, names(hydatLevel)[names(hydatLevel) != 'station_number']],
            rownames = FALSE,
            options = list(pageLength = 5, lengthMenu = c(5, 10, 25, 50))
          )
        })
        
        output$hydatFlowPlot <- renderPlot({
          dt <- data.frame(hydatFlow[hydatFlow$station_number == id, names(hydatFlow)[names(hydatFlow) != 'station_number']])
          dt <- dt %>%
            mutate(day = as.Date(lubridate::make_datetime(year, month))) 
          
          ggplot(dt, aes(x = day, y = monthly_mean)) +
            #geom_line(color="#ffc500", linetype="solid",  linewidth=1.5, lineend = "round") +
            geom_bar(stat = "identity", fill = "#ffc500") +
            labs(
              x = "Date",
              y = "Monthly mean of daily flows (m^3/s)"
            ) + 
            theme(
              panel.background = element_rect(fill='transparent'), #transparent panel bg
              plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
              panel.grid.major = element_blank(), #remove major gridlines
              panel.grid.minor = element_blank(), #remove minor gridlines
              axis.line = element_line(colour = "black"),
              strip.text.x = element_text(size=10),
              strip.text.y = element_text(size=10, vjust = 1),
              axis.text.x = element_text( size = 10),
              axis.text.y = element_text( size = 10),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              plot.title = element_text(size=10, face = "bold")
            ) +
            scale_x_date(date_labels =  "%b %Y") 
        }, res= 96, bg='transparent')
        
        output$hydatLevelPlot <- renderPlot({
          dt <- data.frame(hydatLevel[hydatLevel$station_number == id, names(hydatLevel)[names(hydatLevel) != 'station_number']])
          dt <- dt %>%
            mutate(day = as.Date(lubridate::make_datetime(year, month)))
          
          ggplot(dt, aes(x = day, y = monthly_mean)) +
            #geom_line(color="#ffc500", linetype="solid",  linewidth=1.5, lineend = "round") +
            geom_bar(stat = "identity", fill = "#ffc500") +
            labs(
              x = "Date",
              y = "Monthly mean of daily water level (m)"
            ) + 
            theme(
              panel.background = element_rect(fill='transparent'), #transparent panel bg
              plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
              panel.grid.major = element_blank(), #remove major gridlines
              panel.grid.minor = element_blank(), #remove minor gridlines
              axis.line = element_line(colour = "black"),
              strip.text.x = element_text(size=10),
              strip.text.y = element_text(size=10, vjust = 1),
              axis.text.x = element_text( size = 10),
              axis.text.y = element_text( size = 10),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              plot.title = element_text(size=10, face = "bold")
            ) +
            scale_x_date(date_labels =  "%b %Y") 
        }, res= 96, bg='transparent')
        
        showModal(
          modalDialog(
            title = id,
            tabBox(
              title = strong('Monthly streamflow and water level'),
              width = 12,
              collapsible = FALSE,
              tabPanel(
                title = tagList(icon("chart-line"), "Flow"),
                plotOutput(ns("hydatFlowPlot"))
              ),
              tabPanel(
                title = tagList(icon("chart-line"), "Level"),
                plotOutput(ns("hydatLevelPlot"))
              ),
              tabPanel(
                title = icon("database"),
                strong('Monthly streamflow'),
                DT::dataTableOutput(ns("hydatFlowTbl")),
                br(),
                strong('Monthly level'),
                DT::dataTableOutput(ns("hydatLevelTbl")),
              )
            ),
            size = "l",
            easyClose = TRUE,
            footer = NULL
          )
        )
      } else if (group == 'glbindStation') {
        output$glbindNTbl <- DT::renderDataTable({
          datatable(
            glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'N', names(glbindNutrients)[!names(glbindNutrients) %in% c('station', 'generalized')]],
            rownames = FALSE,
            options = list(pageLength = 5, lengthMenu = c(5, 10, 25, 50))
          )
        })
        output$glbindPTbl <- DT::renderDataTable({
          datatable(
            glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'P', names(glbindNutrients)[!names(glbindNutrients) %in% c('station', 'generalized')]],
            rownames = FALSE,
            options = list(pageLength = 5, lengthMenu = c(5, 10, 25, 50))
          )
        })
        
        output$glbindNPlot <- renderPlot({
          dt <- data.frame(glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'N', ])
          dt <- cbind(day = as.Date(dt$datetime), dt)
          dt <- dt %>%
            group_by(day) %>%
            summarize(mean = mean(value), n = n())
          
          ggplot(dt, aes(x = day, y = mean)) +
            #geom_lines(color="#ffc500", linetype="solid",  linewidth=1.5, lineend = "round") +
            geom_bar(stat = "identity", fill = "#ffc500") +
            labs(
              x = "Date",
              y = "Daily mean ammonia mg/l"
            ) + 
            theme(
              panel.background = element_rect(fill='transparent'), #transparent panel bg
              plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
              panel.grid.major = element_blank(), #remove major gridlines
              panel.grid.minor = element_blank(), #remove minor gridlines
              axis.line = element_line(colour = "black"),
              strip.text.x = element_text(size=10),
              strip.text.y = element_text(size=10, vjust = 1),
              axis.text.x = element_text( size = 10),
              axis.text.y = element_text( size = 10),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              plot.title = element_text(size=10, face = "bold")
            ) +
            scale_x_date(date_labels =  "%b %Y")
        }, res= 96, bg='transparent')
        
        output$glbindPPlot <- renderPlot({
          dt <- data.frame(glbindNutrients[glbindNutrients$station == id & glbindNutrients$generalized == 'P', ])
          dt <- cbind(day = as.Date(dt$datetime), dt)
          dt <- dt %>%
            group_by(day) %>%
            summarize(mean = mean(value), n = n())
          
          ggplot(dt, aes(x = day, y = mean)) +
            #geom_lines(color="#ffc500", linetype="solid",  linewidth=1.5, lineend = "round") +
            geom_bar(stat = "identity", fill = "#ffc500") +
            labs(
              x = "Date",
              y = "Daily mean phosphorus soluble reactive mg/l"
            ) + 
            theme(
              panel.background = element_rect(fill='transparent'), #transparent panel bg
              plot.background = element_rect(fill='transparent', color=NA), #transparent plot bg
              panel.grid.major = element_blank(), #remove major gridlines
              panel.grid.minor = element_blank(), #remove minor gridlines
              axis.line = element_line(colour = "black"),
              strip.text.x = element_text(size=10),
              strip.text.y = element_text(size=10, vjust = 1),
              axis.text.x = element_text( size = 10),
              axis.text.y = element_text( size = 10),
              axis.title.x = element_text(size=10),
              axis.title.y = element_text(size=10),
              plot.title = element_text(size=10, face = "bold")
            ) +
            scale_x_date(date_labels =  "%b %Y")
        }, res= 96, bg='transparent')
        showModal(
          modalDialog(
            title = id,
            tabBox(
              title = strong('Daily nutrient'),
              width = 12,
              collapsible = FALSE,
              tabPanel(
                title = tagList(icon("chart-line"), "N"),
                plotOutput(ns("glbindNPlot"))
              ),
              tabPanel(
                title = tagList(icon("chart-line"), "P"),
                plotOutput(ns("glbindPPlot"))
              ),
              tabPanel(
                title = icon("database"),
                strong('Nutrient: N'),
                DT::dataTableOutput(ns("glbindNTbl")),
                br(),
                strong('Nutrient: P'),
                DT::dataTableOutput(ns("glbindPTbl")),
              )
            ),
            
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