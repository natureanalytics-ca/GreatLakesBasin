

server <- function(input, output, session) {
  callModule(mapServer, id = 'map')
  callModule(twServer, id = 'tw')
}