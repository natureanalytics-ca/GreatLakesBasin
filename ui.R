

#------------------------
#Header
#------------------------

header <- dashboardHeader(
  
  #Branding for the app - client logo, link to website, etc.
  # title = dashboardBrand(
  #   title = "Your brand",
  #   color = "primary",
  #   href = "https://www.google.com",
  #   image = "https://natureanalytics.ca/wp-content/uploads/2021/09/Your-logo-example-e1632748674383.png",
  # ),
  
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
    menuItem(
      tabName = "home",
      text = icon(
        name = NULL,
        class = "fav_icon"
      )
    ),
    br(),
    br(),
    menuItem(
      text = tags$small("Visualization tool"),
      icon = icon("globe"),
      tabName = "visTool"
    ),
    menuItem(
      text = tags$small("Use cases"),
      icon = icon("list"),
      tabName = "useCase"
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



