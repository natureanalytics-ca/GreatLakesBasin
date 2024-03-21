

#------------------------
#Header
#------------------------

header <- dashboardHeader(
  controlbarIcon = shiny::icon("gear"),
  compact = FALSE,
  fixed = TRUE
)


#------------------------
#Sidebar
#------------------------

sidebar <- dashboardSidebar(
  
  #----------------
  #Settings
  #---------------
  minified = FALSE,
  collapsed = FALSE,
  status = "primary",
  
  #-------------
  #Items
  #-------------
  sidebarMenu(
    id='appMenu',
    menuItem(
      tabName = "home",
      text = tagList(
        icon(
          name = NULL,
          class = "fav_icon"
        ),
        div(
          style = "position: absolute; margin-top: 10px; top: 5px; left: 100px;",
          h1("Laurentian Great Lakes"),
          tags$small(tags$em("Spatial toolkit prototype")),
        )
      )
    ),
    br(),
    br(),
    menuItem(
      text = tags$small("Applications"),
      icon = icon("water"),
      menuSubItem(
        text = tags$small("Thames River Watershed"),
        tabName = "useCase",
        icon = NULL
      )
      
    )
  )
)


#----------------------------------
#Body
#----------------------------------

body<-dashboardBody(
  
  #---------------
  #Call to
  #---------------
  useShinyjs(),
  
  
  #----------------------
  #Read styling items
  #----------------------
  use_theme(inputTheme),
  inputSliderSkin,
  includeCSS("www/main.css"),
  
  
  tabItems(
    tabItem(
      tabName = "home",
      mapUI(id = "map")
    ),
    tabItem(
      tabName = "useCase",
      twUI(id = "tw")
    )
  )
)

#-----------------
#Dashboard Page
#-----------------

bs4Dash::dashboardPage(
  header = header,
  sidebar = sidebar,
  body = body,
  footer = footer,
  fullscreen = TRUE,
  dark = NULL,
  help = NULL
)



