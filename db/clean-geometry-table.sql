update :in_table

set :geom = st_makevalid(:geom)

where not st_isvalid(:geom)
