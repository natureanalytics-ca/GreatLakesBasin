url <- 'https://mappingon.ca/data2/'
# url <- 'http://192.168.18.14:8081/data/'

genPopUp <- function(title, fields=NULL) {
  txt <- paste0('<h5>{{', title, '}}</h5>')
  if (!is.null(fields)) {
    for (f in fields) {
      txt <- paste0(txt, '<b>', f, ': </b>{{', f, '}}</br>')
    }
  }
  return(txt)
}

genDiverging <- function(field, options, pal="Spectral") {
  if (length(options) > 11) {
    colors <- colorRampPalette(brewer.pal(11, "Spectral"))(length(options))
  } else {
    colors <- brewer.pal(length(options),"Spectral")
  }
  vals <- list(
    'match',
    list(
      'string',
      list('get', field)
    )
  )
  for (i in c(1: length(options))) {
    vals <- c(vals, options[[i]])
    vals <- c(vals, colors[[i]])
    colors
  }
  vals <- c(vals, '#FFFFFF')
}

sources <- list(
  'agriculture' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'agriculture/{z}/{x}/{y}.pbf'))
  ),
  'bathymetry' = mapbox_source(
    type = 'raster',
    tiles = list(paste0(url, 'bathymetry/{z}/{x}/{y}.pbf'))
  ),
  'bathymetry_contour' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'bathymetry_contour/{z}/{x}/{y}.pbf'))
  ),
  'boundary' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'boundary/{z}/{x}/{y}.pbf'))
  ),
  'ca_watershed' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'ca_watershed/{z}/{x}/{y}.pbf'))
  ),
  'elevation' = mapbox_source(
    type = 'raster',
    tiles = list(paste0(url, 'elev/{z}/{x}/{y}.pbf'))
  ),
  'geology' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'geology/{z}/{x}/{y}.pbf'))
  ),
  'hillshade' = mapbox_source(
    type = 'raster',
    tiles = list(paste0(url, 'hillshade/{z}/{x}/{y}.pbf'))
  ),
  'land_cover' = mapbox_source(
    type = 'raster',
    tiles = list(paste0(url, 'land_cover/{z}/{x}/{y}.pbf'))
  ),
  'nutrient' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'nutrient/{z}/{x}/{y}.pbf'))
  ),
  'slope' = mapbox_source(
    type = 'raster',
    tiles = list(paste0(url, 'slope/{z}/{x}/{y}.pbf'))
  ),
  'waterbody' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'waterbody/{z}/{x}/{y}.pbf'))
  ),
  'watercourse' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'watercourse/{z}/{x}/{y}.pbf'))
  ),
  'watershed' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'watershed/{z}/{x}/{y}.pbf'))
  ),
  'wetland' = mapbox_source(
    type = 'vector',
    tiles = list(paste0(url, 'wetland/{z}/{x}/{y}.pbf'))
  )
)

# Vector layers to add to the map. The order here will be represented in the
# layer selector/legend.
vector_layers <- list(
  'ca_watershed' = list(
    'style' = list(
      'id' = 'ca_watershed',
      'type' = 'fill',
      'source' = 'ca_watershed',
      'source-layer' = 'ca_watershed',
      'paint' = list(
        'fill-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'open_water_area_km2'),
          0.304,
          '#FFFFE0',
          268.348,
          '#FF4500'
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#690E0E'
      ),
      'layout' = list(
        'visibility' = 'visible'
      )
    ),
    'name' = 'Conservation Authority Watersheds',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp(
      'name', c(
        'watershed_area_km2',
        'watershed_mean_elevation_m',
        'watershed_max_elevation_m',
        'watershed_mean_slope_pcent',
        'length_of_main_channel_km',
        'max_channel_elevation_m',
        'min_channel_elevation_m',
        'slope_of_main_channel_m_km',
        'slope_of_main_channel_pcent',
        'annual_temperature_c',
        'annual_precipitation_mm',
        'community_infrastructure_area',
        'agriculture_and_undifferentiated_rural_land_use_area',
        'open_water_area_km2',
        'shoreline',
        'mudflats',
        'marsh',
        'swamp',
        'fen',
        'bog',
        'heath',
        'sparse_treed',
        'treed_upland',
        'deciduous_treed',
        'mixed_treed',
        'coniferous_treed',
        'plantations_treed_cultivated',
        'hedge_rows',
        'disturbance',
        'open_cliff_and_talus',
        'alvar',
        'sand_barren_and_dune',
        'open_tallgrass_prairie',
        'tallgrass_savannah',
        'tallgrass_woodland',
        'sand_gravel_mine_tailings_extraction',
        'bedrock',
        'log10_area',
        'community_prop',
        'ag_prop',
        'wetland_prop',
        'treed_prop'
      )
    )
  ),
  'owb_primary' = list(
    'style' = list(
      'id' = 'owb_primary',
      'type' = 'fill',
      'source' = 'watershed',
      'source-layer' = 'owb_primary',
      'paint' = list(
        'fill-color' = '#7CFC00',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#006400'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'OWB Primary Watersheds',
    'tooltip' = '<b>{{watershed_name}}</b>',
    'popup' = genPopUp('watershed_name', 'watershed_code')
  ),
  'owb_secondary' = list(
    'style' = list(
      'id' = 'owb_secondary',
      'type' = 'fill',
      'source' = 'watershed',
      'source-layer' = 'owb_secondary',
      'paint' = list(
        'fill-color' = '#7CFC00',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#006400'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'OWB Secondary Watersheds',
    'tooltip' = '<b>{{watershed_name}}</b>',
    'popup' = genPopUp('watershed_name', 'watershed_code')
  ),
  'owb_tertiary' = list(
    'style' = list(
      'id' = 'owb_tertiary',
      'type' = 'fill',
      'source' = 'watershed',
      'source-layer' = 'owb_tertiary',
      'paint' = list(
        'fill-color' = '#7CFC00',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#006400'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'OWB Tertiary Watersheds',
    'tooltip' = '<b>{{watershed_name}}</b>',
    'popup' = genPopUp('watershed_name', 'watershed_code')
  ),
  'owb_quaternary' = list(
    'style' = list(
      'id' = 'owb_quaternary',
      'type' = 'fill',
      'source' = 'watershed',
      'source-layer' = 'owb_quaternary',
      'paint' = list(
        'fill-color' = '#7CFC00',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#006400'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'OWB Quaternary Watersheds',
    'tooltip' = '<b>{{watershed_name}}</b>',
    'popup' = genPopUp('watershed_name', 'watershed_code')
  ),
  'adm2' = list(
    'style' = list(
      'id' = 'adm2',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'adm2',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Admin 2 Boundaries',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'on_census_division' = list(
    'style' = list(
      'id' = 'on_census_division',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'on_census_division',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Census Divisions',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'on_census_consolidated_subdivision' = list(
    'style' = list(
      'id' = 'on_census_consolidated_subdivision',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'on_census_consolidated_subdivision',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Census Consolidated Subdivisions',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'on_census_subdivision' = list(
    'style' = list(
      'id' = 'on_census_subdivision',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'on_census_subdivision',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Census Subdivisions',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'us_county' = list(
    'style' = list(
      'id' = 'us_county',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'us_county',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Counties',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'us_tract' = list(
    'style' = list(
      'id' = 'us_tract',
      'type' = 'fill',
      'source' = 'boundary',
      'source-layer' = 'us_tract',
      'paint' = list(
        'fill-color' = '#D3D3D3',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Census Tracts',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name')
  ),
  'glbind_latest_nutrient' = list(
    'style' = list(
      'id' = 'glbind_latest_nutrient',
      'type' = 'circle',
      'source' = 'nutrient',
      'source-layer' = 'glbind_latest_nutrient',
      'paint' = list(
        'circle-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'total_nitrogen_mg_l'),
          0.10000000149011612,
          '#FAA0A0',
          20,
          '#7C3030'
        ),
        'circle-stroke-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Great Lakes Basin Integrated Nutrient Dataset',
    'tooltip' = '<b>{{location}}</b>',
    'popup' = genPopUp(
      'location',
      c(
        'source',
        'station',
        'hu8_catchment',
        'total_nitrogen_mg_l',
        'total_phosphorus_mg_l'
      )
    )
  ),
  'sparrow_nitrogen' = list(
    'style' = list(
      'id' = 'sparrow_nitrogen',
      'type' = 'fill',
      'source' = 'nutrient',
      'source-layer' = 'sparrow_nitrogen',
      'paint' = list(
        'fill-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'accumulated_load_kg'),
          0,
          '#FAA0A0',
          776812396.0815,
          '#7C3030'
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'SPARROW Nitrogen',
    'tooltip' = '<b>{{stream_name}}</b>',
    'popup' = genPopUp(
      'stream_name',
      c(
        'major_drainage_area',
        'tributary',
        'hu8_catchment',
        'accumulated_load_kg',
        'incremental_load_kg',
        'accumulated_yield_kg_km2',
        'incremental_yield_kg_km2',
        'delivered_accumulated_load_kg',
        'delivered_accumulated_yield_kg_km2',
        'delivered_incremental_load_kg',
        'delivered_incremental_yield_kg_km2'
      )
    )
  ),
  'sparrow_phosphorus' = list(
    'style' = list(
      'id' = 'sparrow_phosphorus',
      'type' = 'fill',
      'source' = 'nutrient',
      'source-layer' = 'sparrow_phosphorus',
      'paint' = list(
        'fill-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'accumulated_load_kg'),
          0,
          '#FAA0A0',
          72957068.2188,
          '#7C3030'
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#808080'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'SPARROW Phosphorus',
    'tooltip' = '<b>{{stream_name}}</b>',
    'popup' = genPopUp(
      'stream_name',
      c(
        'major_drainage_area',
        'tributary',
        'hu8_catchment',
        'accumulated_load_kg',
        'incremental_load_kg',
        'accumulated_yield_kg_km2',
        'incremental_yield_kg_km2',
        'delivered_accumulated_load_kg',
        'delivered_accumulated_yield_kg_km2',
        'delivered_incremental_load_kg',
        'delivered_incremental_yield_kg_km2'
      )
    )
  ),
  'on_wetland' = list(
    'style' = list(
      'id' = 'on_wetland',
      'type' = 'fill',
      'source' = 'wetland',
      'source-layer' = 'on_wetland',
      'paint' = list(
        'fill-color' = '#AFEEEE',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#00CED1'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Wetlands',
    'tooltip' = '<b>{{type}}</b>',
    'popup' = genPopUp('type')
  ),
  'us_wetland' = list(
    'style' = list(
      'id' = 'us_wetland',
      'type' = 'fill',
      'source' = 'wetland',
      'source-layer' = 'us_wetland',
      'paint' = list(
        'fill-color' = '#AFEEEE',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#00CED1'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Wetlands',
    'tooltip' = '<b>{{type}}</b>',
    'popup' = genPopUp('type')
  ),
  'on_waterbody' = list(
    'style' = list(
      'id' = 'on_waterbody',
      'type' = 'fill',
      'source' = 'waterbody',
      'source-layer' = 'on_waterbody',
      'paint' = list(
        'fill-color' = '#87CEFA',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#6495ED'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Waterbodies',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name', 'type')
  ),
  'us_waterbody' = list(
    'style' = list(
      'id' = 'us_waterbody',
      'type' = 'fill',
      'source' = 'waterbody',
      'source-layer' = 'us_waterbody',
      'paint' = list(
        'fill-color' = '#87CEFA',
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#6495ED'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Waterbodies',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name', 'type')
  ),
  'on_watercourse' = list(
    'style' = list(
      'id' = 'on_watercourse',
      'type' = 'line',
      'source' = 'watercourse',
      'source-layer' = 'on_watercourse',
      'paint' = list(
        'line-color' = '#87CEFA',
        'line-width' = 0.4
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Watercourses',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name', 'type')
  ),
  'us_watercourse' = list(
    'style' = list(
      'id' = 'us_watercourse',
      'type' = 'line',
      'source' = 'watercourse',
      'source-layer' = 'us_watercourse',
      'paint' = list(
        'line-color' = '#87CEFA',
        'line-width' = 0.4
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Watercourses',
    'tooltip' = '<b>{{name}}</b>',
    'popup' = genPopUp('name', 'type')
  ),
  'bathymetry_contour' = list(
    'style' = list(
      'id' = 'bathymetry_contour',
      'type' = 'line',
      'source' = 'bathymetry_contour',
      'source-layer' = 'bathymetry_contour',
      'paint' = list(
        'line-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'depth'),
          -244,
          '#F4A460',
          0,
          '#800000'
        ),
        'line-width' = 0.4
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Bathymetry Contours',
    'tooltip' = '<b>{{depth}}</b>',
    'popup' = genPopUp('depth')
  ),
  'on_geology' = list(
    'style' = list(
      'id' = 'on_geology',
      'type' = 'fill',
      'source' = 'geology',
      'source-layer' = 'on_geology',
      'paint' = list(
        'fill-color' = genDiverging(
          'unit_name',
          c(
            "Alkalic Intrusive Suite and Carbonatite (circa 1.1 to 1.2 Ga)",
            "Alkalic plutonic rocks",
            "Anorthosite and alkalic igneous rocks",
            "Carbonate metasedimentary rocks",
            "Carbonate-alkalic intrusive suite (450 to 600 Ma)",
            "Carbonatite-alkalic intrusive suite (circa 1.8 to 1.9 Ga)",
            "Clastic metasedimentary rocks",
            "Coarse clastic metasedimentary rocks",
            "Diorite-monzondiorite-granodiorite suite  (saturated to oversaturated suite)",
            "Early felsic plutonic rock",
            "Felsic igneous rocks",
            "Felsic intrusive rocks",
            "Felsic to intermediate metavolcanic rock",
            "Felsic to intermediate metavolcanic rocks",
            "Foliated tonalite suite",
            "Gneisses of metasedimentary origin",
            "Gneissic tonalite suite",
            "Hornblendite - nepheline syenite suite (saturated to undersaturated suite)",
            "Late felsic plutonic rocks",
            "Mafic and related intrusive rocks and mafic dikes",
            "Mafic and ultramafic intrusive rocks and mafic dikes",
            "Mafic and ultramafic rocks",
            "Mafic dikes and related intrusive rocks (Keweenawan age) (circa 1.1 to 1.2 Ga)",
            "Mafic intrusive rocks",
            "Mafic intrusive rocks, mafic dikes and mafic sills",
            "Mafic metavolcanic and metasedimentary rocks",
            "Mafic rocks",
            "Mafic to felsic metavolcanic rocks",
            "Mafic to intermediate metavolcanic rocks",
            "Mafic to ultramafic metavolcanic rocks",
            "Mafic to ultramafic plutonic rocks",
            "Massive granodiorite to granite",
            "Metasedimentary rocks",
            "Metasedimentary rocks and mafic to ultramafic metavolcanic rocks",
            "Migmatitic rocks and gneisses of undetermined protolith",
            "Migmatized supracrustal rocks",
            "Muscovite-bearing granitic rocks",
            "Sedimentary rocks",
            "Sudbury Igneous Complex (1850 Ma)",
            "Tectonite unit",
            "Trans-Hudson Orogen Supracrustal rocks / sedimentary rocks (Sutton Inliers)",
            "Volcanic rocks"
          )
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#690E0E'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Geology',
    'tooltip' = '<b>{{unit_name}}</b>',
    'popup' = genPopUp('unit_name', c('strat', 'rock_type'))
  ),
  'us_geology' = list(
    'style' = list(
      'id' = 'us_geology',
      'type' = 'fill',
      'source' = 'geology',
      'source-layer' = 'us_geology',
      'paint' = list(
        'fill-color' = genDiverging(
          'rock_type',
          c(
            "Igneous and Metamorphic, undifferentiated",
            "Igneous and Sedimentary, undifferentiated",
            "Igneous, intrusive",
            "Igneous, volcanic",
            "Melange",
            "Metamorphic and Sedimentary, undifferentiated",
            "Metamorphic, amphibolite",
            "Metamorphic, carbonate",
            "Metamorphic, gneiss",
            "Metamorphic, intrusive",
            "Metamorphic, schist",
            "Metamorphic, sedimentary clastic",
            "Metamorphic, serpentinite",
            "Metamorphic, undifferentiated",
            "Metamorphic, volcanic",
            "Sedimentary, carbonate",
            "Sedimentary, clastic",
            "Sedimentary, iron formation, undifferentiated",
            "Sedimentary, undifferentiated",
            "Tectonite, undifferentiated",
            "Unconsolidated, undifferentiated",
            "Water"
          )
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#690E0E'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Geology',
    'tooltip' = '<b>{{rock_type}}</b>',
    'popup' = genPopUp('rock_type', 'unit_link')
  ),
  'on_farm_area' = list(
    'style' = list(
      'id' = 'on_farm_area',
      'type' = 'fill',
      'source' = 'agriculture',
      'source-layer' = 'on_farm_area',
      'paint' = list(
        'fill-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'farmed_area_ha'),
          -1,
          '#E6E6FA',
          256846,
          '#800080'
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#690E0E'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'ON Agriculture',
    'tooltip' = '<b>{{ccsname}}</b>',
    'popup' = genPopUp('ccsname', c('farmed_area_ha'))
  ),
  'us_farm_area' = list(
    'style' = list(
      'id' = 'us_farm_area',
      'type' = 'fill',
      'source' = 'agriculture',
      'source-layer' = 'us_farm_area',
      'paint' = list(
        'fill-color' = list(
          'interpolate',
          list('linear'),
          list('get', 'farmed_area_percent'),
          0,
          '#E6E6FA',
          99.2,
          '#800080'
        ),
        'fill-opacity' = 0.4,
        'fill-outline-color' = '#690E0E'
      ),
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'US Agriculture',
    'tooltip' = '<b>{{fips}}</b>',
    'popup' = genPopUp('fips', c('farmed_area_percent'))
  )
)

# Raster layers to add to the map. The order here will be represented in the
# layer selector/legend.
raster_layers = list(
  'bathymetry' = list(
    'style' = list(
      'id' = 'bathymetry',
      'type' = 'raster',
      'source' = 'bathymetry',
      'layout' = list(
        'visibility' = 'visible'
      )
    ),
    'name' = 'Bathymetry'
  ),
  'slope' = list(
    'style' = list(
      'id' = 'slope',
      'type' = 'raster',
      'source' = 'slope',
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Slope'
  ),
  'elevation' = list(
    'style' = list(
      'id' = 'elevation',
      'type' = 'raster',
      'source' = 'elevation',
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Elevation'
  ),
  'hillshade' = list(
    'style' = list(
      'id' = 'hillshade',
      'type' = 'raster',
      'source' = 'hillshade',
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Terrain (Hillshade)'
  ),
  'land_cover' = list(
    'style' = list(
      'id' = 'land_cover',
      'type' = 'raster',
      'source' = 'land_cover',
      'layout' = list(
        'visibility' = 'none'
      )
    ),
    'name' = 'Land Cover'
  )
)
