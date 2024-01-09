

server <- function(input, output, session) {
  callModule(mapServer, id = 'map')
  callModule(lpwServer, id = 'lpw')
}