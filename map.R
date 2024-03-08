# Define UI for map tab.
mapUI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      column(
        8,
        box(
          title = "Laurentian Great Lakes visualization tool",
          width = 12,
          status = "primary",
          collapsible = FALSE,
          mapboxerOutput(ns('map'), height=500)
        )
      ),
      column(
        4,
        tabBox(
          type = 'tabs',
          width = 12,
          status = "primary",
          collapsible = FALSE,
          tabPanel(
            title = "Vector",
            pickerInput(
              ns('vectorSel'),
              'Vector layers',
              multiple = TRUE,
              #selected = 'ca_watershed',
              #choiceNames = as.vector(unlist(vector_reactive)[grepl('.name',names(unlist(vector_reactive)),fixed=T)]),
              #choiceValues = names(vector_reactive)
              choices = setNames(
                names(vector_layers),
                as.vector(unlist(vector_layers)[grepl('.name',names(unlist(vector_layers)),fixed=T)])
              ),
              options = pickerOptions(
                dropdownAlignRight = 'auto',
                maxOptions = 3,
                maxOptionsText = "Select up to 3",
              )
            ),
            br(),
            uiOutput(ns("vecCol1")),
            br(),
            uiOutput(ns("vecCol2")),
            br(),
            uiOutput(ns("vecCol3"))
          ),
          tabPanel(
            title = "Raster",
            pickerInput(
              ns('rasterSel'),
              'Raster layers',
              #choiceNames = c(as.vector(unlist(raster_layers)[grepl('.name',names(unlist(raster_layers)),fixed=T)]), 'None'),
              #choiceValues = c(names(raster_layers), 'none')
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
    # add_popups('ca_watershed_tkn', vector_layers[['ca_watershed_tkn']][['popup']]) %>%
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
        tags$small(tags$strong(nm)),
        div(
          style = "float: right;",
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
              numericInput(
                inputId = ns("vecOpacity1"), 
                label = tags$small("Opacity"), 
                min = 0, 
                max = 1,
                step = 0.05,
                value = opacity,
                width = "100%"
              )
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
        tags$small(tags$strong(nm)),
        div(
          style = "float: right;",
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
              numericInput(
                inputId = ns("vecOpacity2"),
                label = tags$small("Opacity"),
                min = 0,
                max = 1,
                value = opacity,
                step = 0.05,
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
        tags$small(tags$strong(nm)),
        div(
          style = "float: right;",
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
              numericInput(
                inputId = ns("vecOpacity3"),
                label = tags$small("Opacity"),
                min = 0,
                max = 1,
                value = opacity,
                step = 0.05,
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