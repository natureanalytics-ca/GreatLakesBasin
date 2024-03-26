# Great Lakes Basin Watersheds


## Tile server setup

Map tiles server hosted on Digital Ocean at: 142.93.149.247 with the following config:

```
Docker 25.0.3 on Ubuntu 22.04
1 GB RAM
1 CPU
25 GB SSD
```

Update and install nginx and certbot for SSL
```
apt update
apt upgrade -y
apt install nginx -y
snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
```

Ports 80 (HTTP) and 443 (HTTPS) were opened in the digital ocean web app, and on the server as:

```
ufw allow 80
ufw allow 443
```

Setup dirs in home dir:
```
git clone https://github.com/natureanalytics-ca/GreatLakesBasin.git

mkdir $HOME/data
```

mbtiles files were then uploaded to $HOME/data from the data processing server (see "Data processing" section below for how these were created) as:
```
cd ${DATA_DIR}/served/mbtiles

for i in agriculture bathymetry bathymetry_contour boundary ca_watershed elev geology hillshade land_cover mines nutrient wetland slope waterbody watercourse watershed wetland thames-watershed-elev thames-watershed-hillshade thames-watershed-land-cover thames_watershed_cartographic thames_watershed_contextual thames_watershed_feature
do
    echo ${i}.mbtiles >> fileList.txt
done

rsync -av --files-from=fileList.txt . root@142.93.149.247:~/data

rm fileList.txt
```

Start the tile server
```
docker pull maptiler/tileserver-gl

cd GreatLakesBasin

docker compose up -d
```


## Data processing

Data was aquired and processed on an ubuntu server 22.04 LTS machine with the following config:

- 4 core / 8 thread cpu
- 32 gb RAM
- NVMe SSD storage

With the following libs installed and in use (among others):

- docker + docker-compose
- psql (postgresql-client)
- gdal 3.4.1 (gdal-bin libgdal-dev libgeos-dev libgeos++-dev proj-bin)
- python3.10 + python3.10-venv + python3-gdal
- libvips libvips-dev libtiff5 optipng pngquant csvkit miller sqlite3 nano

The entire workflow used to create a local database, download and ingest data, and then export layers and tables for the tile server and R Shiny app is listed below.

A copy of the scripts and docker-compose.yaml file refered to below are held in the `db` directory of this repository.


### Define Variables:

```
nano ${HOME}/workspace/repos/projects/nature-analytics/.env

export DB_DIR=${HOME}/volumes/projects/nature-analytics
export DB_PASSWORD=*****
export READ_ONLY_USER=read_only
export READ_ONLY_PASSWORD=*****
export DB=great_lakes_basins
export DB_PORT=54323
export DB_USER=postgres
export DB_HOST=localhost
export ENV=${HOME}/workspace/envs/nature-analytics
export SCRIPTS=${HOME}/workspace/repos/projects/nature-analytics
export PGPASSWORD=${DB_PASSWORD}
export PGSTRING="host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"
export DATA_DIR=${HOME}/workspace/project-data/nature-analytics/great-lakes-basins
```

### Build db.

```
docker pull postgis/postgis:15-3.4

source ${HOME}/workspace/repos/projects/nature-analytics/.env && cd ${SCRIPTS} && docker compose up -d

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB_USER} -U ${DB_USER} -c "create database ${DB};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create extension postgis;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create extension postgis_raster;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create user ${READ_ONLY_USER} with password '${READ_ONLY_PASSWORD}';"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema agriculture;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema bathymetry;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema boundary;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema ca_data"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema elevation;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema geology;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema land_cover;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema mine;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema nutrient;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema soil;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema waterbody;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema watercourse;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema watershed;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema wetland;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema agriculture TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema bathymetry TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema boundary TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema ca_data TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema elevation TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema geology TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema land_cover TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema mine TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema nutrient TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema soil TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema waterbody TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema watercourse TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema watershed TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema wetland TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema agriculture grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema bathymetry grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema boundary grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema ca_data grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema elevation grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema geology grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema land_cover grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema mine grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema nutrient grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema soil grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema waterbody grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema watercourse grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema watershed grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema wetland grant select on tables to ${READ_ONLY_USER};"
```

### Set up Python

```
python3 -m venv ${ENV} --system-site-packages
source ${ENV}/bin/activate
pip install xlsx2csv

git clone https://github.com/mapbox/mbutil.git
cd mbutil
sudo python3 setup.py install
mb-util
```


### MODULE A

#### Great lakes watersheds

```
# Download MNRF watershed boundaries: https://geohub.lio.gov.on.ca/maps/mnrf::ontario-watershed-boundaries-owb/about
mkdir -p ${DATA_DIR}/watershed; cd ${DATA_DIR}/watershed

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OWBPRIM.zip

unzip OWBPRIM.zip -d OWBPRIM

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watershed \
    -nlt POLYGON -nln owb_primary -f PostgreSQL -makevalid -t_srs EPSG:4326  \
    -sql "select WATERSHED_NAME, WATERSHED_CODE, Shape from ONT_WSHED_BDRY_PRI_DERIVED where WATERSHED_CODE = '02'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OWBPRIM/Non_Sensitive.gdb

rm -R OWBPRIM.zip

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OWBSEC.zip

unzip OWBSEC.zip -d OWBSEC

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watershed \
    -nlt POLYGON -nln owb_secondary -f PostgreSQL -makevalid -t_srs EPSG:4326  \
    -sql "select WATERSHED_NAME, WATERSHED_CODE, Shape from ONT_WSHED_BDRY_SEC_DERIVED where substr(WATERSHED_CODE, 0, 2) = '02'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OWBSEC/Non_Sensitive.gdb

rm -R OWBSEC.zip

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OWBTERT.zip

unzip OWBTERT.zip -d OWBTERT

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watershed \
    -nlt POLYGON -nln owb_tertiary -f PostgreSQL -makevalid -t_srs EPSG:4326  \
    -sql "select WATERSHED_NAME, WATERSHED_CODE, Shape from ONT_WSHED_BDRY_TERT_DERIVED where substr(WATERSHED_CODE, 0, 2) = '02'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OWBTERT/Non_Sensitive.gdb

rm -R OWBTERT.zip

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OWBQUAT.zip

unzip OWBQUAT.zip -d OWBQUAT

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watershed \
    -nlt POLYGON -nln owb_quaternary -f PostgreSQL -makevalid -t_srs EPSG:4326  \
    -sql "select WATERSHED_NAME, WATERSHED_CODE, Shape from ONT_WSHED_BDRY_QUAT_DERIVED where substr(WATERSHED_CODE, 0, 2) = '02'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OWBQUAT/Non_Sensitive.gdb

rm -R OWBQUAT.zip

# Get bounds of great lakes basin: -93.213865, 40.394681, -73.852756, 50.779126
ogrinfo -so PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" watershed.owb_primary | grep "Extent:"
```

#### SRTM1: 30m elevation

```
# Download SRTM reference grid and extract tiles within buffer.
mkdir -p ${DATA_DIR}/srtm; cd ${DATA_DIR}/srtm

wget https://dwtkns.com/srtm30m/srtm30m_bounding_boxes.json

ogr2ogr -sql "select dataFile from srtm30m_bounding_boxes" -spat -93.5 40 -73.5 51 srtm-grid-cells.csv srtm30m_bounding_boxes.json 

# Download selected SRTM tiles (requires registering for a USGS Earth Data account)
export USGS_USER=abc
export USGS_PASSWORD=*****

time . ${SCRIPTS}/downloadSRTM.sh srtm-grid-cells.csv "${DATA_DIR}/srtm/tiles" "${USGS_USER}" "${USGS_PASSWORD}"

rm *hgt.zip

# Merge tiles and clip to GL basin.
gdalbuildvrt ${DATA_DIR}/srtm/srtm.vrt ${DATA_DIR}/srtm/tiles/*.hgt

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl watershed.owb_primary -crop_to_cutline \
    ${DATA_DIR}/srtm/srtm.vrt \
    ${DATA_DIR}/srtm/srtm.tif

# Create slope and hillshade rasters.
gdaldem hillshade -s 111120 ${DATA_DIR}/srtm/srtm.tif ${DATA_DIR}/srtm/hillshade.tif

gdaldem slope -s 111120 ${DATA_DIR}/srtm/srtm.tif ${DATA_DIR}/srtm/slope.tif

# Import to db - for local use only e.g. QGIS.
raster2pgsql -s 4269 -d -C -l 2,4,8,16 -I -F -t 1000x1000 ${DATA_DIR}/srtm/srtm.tif elevation.elevation_30m | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

raster2pgsql -s 4269 -d -C -l 2,4,8,16 -I -F -t 1000x1000 ${DATA_DIR}/srtm/hillshade.tif elevation.hillshade_30m | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

raster2pgsql -s 4269 -d -C -l 2,4,8,16 -I -F -t 1000x1000 ${DATA_DIR}/srtm/slope.tif elevation.slope_30m | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}
```

#### Watercourses and waterbodies

```
mkdir -p ${DATA_DIR}/waterbody; cd ${DATA_DIR}/waterbody

# ON water body - Ontario Hydro Network (OHN): https://geohub.lio.gov.on.ca/datasets/mnrf::ontario-hydro-network-ohn-waterbody/explore
wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OHNWBDY.zip

unzip OHNWBDY.zip -d OHNWBDY

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=waterbody \
    -nlt POLYGON -nln ohn_waterbody -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select WATERBODY_TYPE as type, PERMANENCY, OFFICIAL_NAME_LABEL as name, Shape from OHN_WATERBODY" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OHNWBDY/Non_Sensitive.gdb

rm OHNWBDY.zip

# Drop excess features.
time psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "delete from waterbody.ohn_waterbody using waterbody.ohn_waterbody as wb left outer join watershed.owb_primary ws on st_intersects(wb.geom, ws.geom) where ws.fid is null"

time psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "delete from watercourse.ohn_watercourse using watercourse.ohn_watercourse as wc left outer join watershed.owb_primary ws on st_intersects(wc.geom, ws.geom) where ws.fid is null"

# ON watercourse - Ontario Hydro Network (OHN): https://geohub.lio.gov.on.ca/datasets/mnrf::ontario-hydro-network-ohn-watercourse/explore
wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/OHNWCRS.zip

unzip OHNWCRS.zip -d OHNWCRS

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watercourse \
    -nlt MULTILINESTRING -nln ohn_watercourse -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select WATERCOURSE_TYPE as type, PERMANENCY, OFFICIAL_NAME_LABEL as name, Shape from OHN_WATERCOURSE" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    OHNWCRS/Non_Sensitive.gdb

rm OHNWCRS.zip

# US great lakes data - National Hydrography Database (NHD): https://www.epa.gov/waterdata/nhdplus-great-lakes-data-vector-processing-unit-04
wget https://dmap-data-commons-ow.s3.amazonaws.com/NHDPlusV21/Data/NHDPlusGL/NHDPlusV21_GL_04_NHDSnapshotFGDB_08.7z

7za x NHDPlusV21_GL_04_NHDSnapshotFGDB_08.7z -o NHD

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=waterbody \
    -nlt POLYGON -nln nhd_waterbody -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select FCode as type, GNIS_Name as name, Shape from NHDArea" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    NHD/NHDPlusGL/NHDPlus04/NHDSnapshot/NHDSnapshot.gdb

ogr2ogr \
    -nlt POLYGON -nln nhd_waterbody -f PostgreSQL -makevalid -append -t_srs EPSG:4326 \
    -sql "select FCode as type, GNIS_Name as name, Shape from NHDWaterbody" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=waterbody" \
    NHD/NHDPlusGL/NHDPlus04/NHDSnapshot/NHDSnapshot.gdb

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=watercourse \
    -nlt MULTILINESTRING -nln nhd_flowline -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select FCode as type, GNIS_Name as name, Shape from NHDFlowline" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    NHD/NHDPlusGL/NHDPlus04/NHDSnapshot/NHDSnapshot.gdb

ogr2ogr -progress -f PostgreSQL \
    -lco OVERWRITE=TRUE -lco FID=fid -lco SCHEMA=watercourse \
    -nln nhd_fcode -f PostgreSQL  \
    -sql "select fcode, description from NHDFCode" \
    PG:"${PGSTRING}" \
    NHD/NHDPlusGL/NHDPlus04/NHDSnapshot/NHDSnapshot.gdb

rm NHDPlusV21_GL_04_NHDSnapshotFGDB_08.7z

# Great lakes polygon layer exported to GPKG from the Great Lakes Commissions ArcGIS Online app, and manually downloaded: https://www.glc.org/greatlakesgis

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=waterbody \
    -nlt MULTIPOLYGON -nln great_lake_waterbody -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select SHAPE from main_lakes" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    Great_Lakes_Shorelines.gpkg
```

#### Land cover

```
mkdir ${DATA_DIR}/land-cover; cd ${DATA_DIR}/land-cover

# CEC north america land cover map: http://www.cec.org/north-american-environmental-atlas/land-cover-30m-2020/
wget http://www.cec.org/files/atlas_layers/1_terrestrial_ecosystems/1_01_0_land_cover_2020_30m/land_cover_2020_30m_tif.zip

unzip land_cover_2020_30m_tif.zip

# Clip to GL basin, with reprojection to canada lambert, as existing spatial ref has no SRID.
gdalwarp \
    -t_srs EPSG:3347 -tr 30 30 \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl watershed.owb_primary -crop_to_cutline \
    land_cover_2020_30m_tif/NA_NALCMS_landcover_2020_30m/data/NA_NALCMS_landcover_2020_30m.tif \
    landcover_2020_clipped.tif

# Import to db - for local use only e.g. QGIS.
raster2pgsql -s 3347 -d -C -l 2,4,8,16 -I -F -t 1000x1000 ${DATA_DIR}/land-cover/landcover_2020_clipped.tif land_cover.land_cover_2020 | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

rm land_cover_2020_30m_tif.zip
```

#### Administration boundaries

```
mkdir ${DATA_DIR}/boundaries; cd ${DATA_DIR}/boundaries

# CA 2021 census boundaries: https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21

# Province/territory
wget https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lpr_000a21f_e.zip

unzip lpr_000a21f_e.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt MULTIPOLYGON -nln ontario -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select PRNAME as name, SHAPE from lpr_000a21f_e where PRUID = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    lpr_000a21f_e.gdb

rm lpr_000a21f_e.zip

# Census division
wget https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcd_000a21f_e.zip

unzip lcd_000a21f_e.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt MULTIPOLYGON -nln on_census_division -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select CDNAME as name, CDTYPE as type, SHAPE from lcd_000a21f_e where PRUID = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    lcd_000a21f_e.gdb

rm lcd_000a21f_e.zip

# Census sub-division
wget https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lcsd000a21f_e.zip

unzip lcsd000a21f_e.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt MULTIPOLYGON -nln on_census_subdivision -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select CSDNAME as name, CSDTYPE as type, SHAPE from lcsd000a21f_e where PRUID = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    lcsd000a21f_e.gdb

rm lcsd000a21f_e.zip

# Census consolidated sub-division
wget https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lccs000a21f_e.zip

unzip lccs000a21f_e.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt MULTIPOLYGON -nln on_census_consolidated_subdivision -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select CCSNAME as name, SHAPE from lccs000a21f_e where PRUID = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    lccs000a21f_e.gdb

rm lccs000a21f_e.zip

# US TIGER/Line 2022 census boundaries from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php

# US State
wget https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip

unzip tl_2022_us_state.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt POLYGON -nln us_state -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select GEOID, NAME, OGR_Geometry from tl_2022_us_state where GEOID in ('17', '27', '55', '42', '39', '36', '26', '18')" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    tl_2022_us_state.shp

rm tl_2022_us_state.zip

# US Counties
wget https://www2.census.gov/geo/tiger/TIGER2022/COUNTY/tl_2022_us_county.zip

unzip tl_2022_us_county.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
    -nlt POLYGON -nln us_county -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select STATEFP, GEOID, NAME, OGR_Geometry from tl_2022_us_county where STATEFP in ('17', '27', '55', '42', '39', '36', '26', '18')" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    tl_2022_us_county.shp

rm tl_2022_us_county.zip

# US census tracts
for state in 17 27 55 42 39 36 26 18
do
    l=tl_2022_${state}_tract
    f=${l}.zip  

    wget https://www2.census.gov/geo/tiger/TIGER2022/TRACT/${f}

    unzip ${f} -d tracts

    rm ${f}

    if [ ${state} = 17 ]
    then
        ogr2ogr \
            -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=boundary \
            -nlt POLYGON -nln us_tract -f PostgreSQL -makevalid -t_srs EPSG:4326 \
            -sql "select STATEFP, COUNTYFP, GEOID, NAME, OGR_Geometry from ${l}" \
            PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
            tracts/${l}.shp
    else
        ogr2ogr \
            -nlt POLYGON -nln us_tract -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
            -sql "select STATEFP, COUNTYFP, GEOID, NAME, OGR_Geometry from ${l}" \
            PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=boundary" \
            tracts/${l}.shp
    fi
done
```

#### Bathymetry

```
# Great lakes data available from NOAA: https://www.ngdc.noaa.gov/mgg/greatlakes/

mkdir ${DATA_DIR}/bathymetry; cd ${DATA_DIR}/bathymetry

# Download bathymetry tiffs for each lake and clip - partial for L. Superior.
wget https://www.ngdc.noaa.gov/mgg/greatlakes/erie/data/geotiff/erie_lld.geotiff.tar.gz

tar xvzf erie_lld.geotiff.tar.gz

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl waterbody.great_lake_waterbody -crop_to_cutline \
    ${DATA_DIR}/bathymetry/erie_lld/erie_lld.tif \
    ${DATA_DIR}/bathymetry/lake_erie.tif

rm erie_lld.geotiff.tar.gz

wget https://www.ngdc.noaa.gov/mgg/greatlakes/huron/data/geotiff/huron_lld.geotiff.tar.gz

tar xvzf huron_lld.geotiff.tar.gz

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl waterbody.great_lake_waterbody -crop_to_cutline \
    ${DATA_DIR}/bathymetry/huron_lld/huron_lld.tif \
    ${DATA_DIR}/bathymetry/lake_huron.tif

rm huron_lld.geotiff.tar.gz

wget https://www.ngdc.noaa.gov/mgg/greatlakes/michigan/data/geotiff/michigan_lld.geotiff.tar.gz

tar xvzf michigan_lld.geotiff.tar.gz

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl waterbody.great_lake_waterbody -crop_to_cutline \
    ${DATA_DIR}/bathymetry/michigan_lld/michigan_lld.tif \
    ${DATA_DIR}/bathymetry/lake_michigan.tif

rm michigan_lld.geotiff.tar.gz

wget https://www.ngdc.noaa.gov/mgg/greatlakes/ontario/data/geotiff/ontario_lld.geotiff.tar.gz

tar xvzf ontario_lld.geotiff.tar.gz

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl waterbody.great_lake_waterbody -crop_to_cutline \
    ${DATA_DIR}/bathymetry/ontario_lld/ontario_lld.tif \
    ${DATA_DIR}/bathymetry/lake_ontario.tif

rm ontario_lld.geotiff.tar.gz

wget https://www.ngdc.noaa.gov/mgg/greatlakes/superior/data/geotiff/superior_lld.geotiff.tar.gz

tar xvzf superior_lld.geotiff.tar.gz

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl waterbody.great_lake_waterbody -crop_to_cutline \
    ${DATA_DIR}/bathymetry/superior_lld/superior_lld.tif \
    ${DATA_DIR}/bathymetry/lake_superior.tif

rm superior_lld.geotiff.tar.gz

# Merge files.
gdalbuildvrt ${DATA_DIR}/bathymetry/great_lakes.vrt ${DATA_DIR}/bathymetry/lake_erie.tif ${DATA_DIR}/bathymetry/lake_huron.tif ${DATA_DIR}/bathymetry/lake_michigan.tif ${DATA_DIR}/bathymetry/lake_ontario.tif ${DATA_DIR}/bathymetry/lake_superior.tif

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl watershed.owb_primary -crop_to_cutline \
    ${DATA_DIR}/bathymetry/great_lakes.vrt \
    ${DATA_DIR}/bathymetry/great_lakes.tif

# Import to db - for local use only e.g. QGIS.
raster2pgsql -s 4269 -d -C -l 2,4,8,16 -I -F -t 1000x1000 ${DATA_DIR}/bathymetry/great_lakes.tif bathymetry.great_lake_bathymetry | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

# Download contours for each lake - not available for L. Superior.
wget https://www.ngdc.noaa.gov/mgg/greatlakes/erie/data/shapefiles/Lake_Erie_Contours.zip

unzip Lake_Erie_Contours.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=bathymetry \
    -nlt MULTILINESTRING -nln contour -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select 'Erie' as name, zvalue as depth, OGR_Geometry from Lake_Erie_Contours" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/bathymetry/Lake_Erie_Contours.shp

rm Lake_Erie_Contours.zip

wget https://www.ngdc.noaa.gov/mgg/greatlakes/huron/data/shapefiles/Lake_Huron_Contours.zip

unzip Lake_Huron_Contours.zip

ogr2ogr \
    -nlt MULTILINESTRING -nln contour -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'Huron' as name, zvalue as depth, OGR_Geometry from Lake_Huron_Contours" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=bathymetry" \
    ${DATA_DIR}/bathymetry/Lake_Huron_Contours.shp

rm Lake_Huron_Contours.zip

wget https://www.ngdc.noaa.gov/mgg/greatlakes/michigan/data/shapefiles/Lake_Michigan_Contours.zip

unzip Lake_Michigan_Contours.zip

ogr2ogr \
    -nlt MULTILINESTRING -nln contour -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'Michigan' as name, zvalue as depth, OGR_Geometry from Lake_Michigan_Contours" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=bathymetry" \
    ${DATA_DIR}/bathymetry/Lake_Michigan_Contours.shp

rm Lake_Michigan_Contours.zip

wget https://www.ngdc.noaa.gov/mgg/greatlakes/ontario/data/shapefiles/Lake_Ontario_Contours.zip

unzip Lake_Ontario_Contours.zip

ogr2ogr \
    -nlt MULTILINESTRING -nln contour -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'Ontario' as name, zvalue as depth, OGR_Geometry from Lake_Ontario_Contours" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=bathymetry" \
    ${DATA_DIR}/bathymetry/Lake_Ontario_Contours.shp

rm Lake_Ontario_Contours.zip
```

#### Wetlands

```
mkdir ${DATA_DIR}/wetland; cd ${DATA_DIR}/wetland

# ON MNRF: https://geohub.lio.gov.on.ca/datasets/mnrf::wetlands/about

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/WETLAND.zip

unzip WETLAND.zip -d WETLAND

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=wetland \
    -nlt MULTIPOLYGON -nln on_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select WETLAND_TYPE as type from WETLAND" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/wetland/WETLAND/Non_Sensitive.gdb

rm WETLAND.zip

# US Fish & Wildlife service: https://www.fws.gov/program/national-wetlands-inventory/download-state-wetlands-data

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/NY_shapefile_wetlands.zip

unzip NY_shapefile_wetlands.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=wetland \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select 'NY' as state, wetland_ty as type from NY_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'New York'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/wetland/NY_shapefile_wetlands/NY_Wetlands.shp

rm NY_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/IL_shapefile_wetlands.zip

unzip IL_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'IL' as state, wetland_ty as type from IL_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Illinois'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/IL_shapefile_wetlands/IL_Wetlands.shp

rm IL_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/WI_shapefile_wetlands.zip

unzip WI_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'WI' as state, wetland_ty as type from WI_Wetlands_NorthEast where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Wisconsin'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/WI_shapefile_wetlands/WI_Wetlands_NorthEast.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'WI' as state, wetland_ty as type from WI_Wetlands_NorthWest_1 where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Wisconsin'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/WI_shapefile_wetlands/WI_Wetlands_NorthWest_1.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'WI' as state, wetland_ty as type from WI_Wetlands_NorthWest_2 where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Wisconsin'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/WI_shapefile_wetlands/WI_Wetlands_NorthWest_2.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'WI' as state, wetland_ty as type from WI_Wetlands_South where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Wisconsin'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/WI_shapefile_wetlands/WI_Wetlands_South.shp

rm WI_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/MN_shapefile_wetlands.zip

unzip MN_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MN' as state, wetland_ty as type from MN_Wetlands_North_East where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Minnesota'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MN_shapefile_wetlands/MN_Wetlands_North_East.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MN' as state, wetland_ty as type from MN_Wetlands_North_West where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Minnesota'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MN_shapefile_wetlands/MN_Wetlands_North_West.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MN' as state, wetland_ty as type from MN_Wetlands_South where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Minnesota'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MN_shapefile_wetlands/MN_Wetlands_South.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MN' as state, wetland_ty as type from MN_Wetlands_Central_East where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Minnesota'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MN_shapefile_wetlands/MN_Wetlands_Central_East.shp

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MN' as state, wetland_ty as type from MN_Wetlands_Central_West where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Minnesota'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MN_shapefile_wetlands/MN_Wetlands_Central_West.shp

rm MN_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/PA_shapefile_wetlands.zip

unzip PA_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'PA' as state, wetland_ty as type from PA_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Pennsylvania'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/PA_shapefile_wetlands/PA_Wetlands.shp

rm PA_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/OH_shapefile_wetlands.zip

unzip OH_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'OH' as state, wetland_ty as type from OH_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Ohio'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/OH_shapefile_wetlands/OH_Wetlands.shp

rm OH_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/MI_shapefile_wetlands.zip

unzip MI_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'MI' as state, wetland_ty as type from MI_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Michigan'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/MI_shapefile_wetlands/MI_Wetlands.shp

rm MI_shapefile_wetlands.zip

wget https://documentst.ecosphere.fws.gov/wetlands/data/State-Downloads/IN_shapefile_wetlands.zip

unzip IN_shapefile_wetlands.zip

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'IN' as state, wetland_ty as type from IN_Wetlands where WETLAND_TY NOT IN ('Lake', 'Riverine', 'Estuarine and Marine Deepwater', 'Freshwater Pond')" \
    -clipdst PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -clipdstlayer boundary.us_state -clipdstwhere "name = 'Indiana'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=wetland" \
    ${DATA_DIR}/wetland/IN_shapefile_wetlands/IN_Wetlands.shp

rm IN_shapefile_wetlands.zip
```

#### Geology 

```
mkdir ${DATA_DIR}/geology; cd ${DATA_DIR}/geology

# ON bedrock geology: https://www.geologyontario.mndm.gov.on.ca/ogsearth.html
wget https://prd-0420-geoontario-0000-blob-cge0eud7azhvfsf7.z01.azurefd.net/lrc-geology-documents/publication/MRD126-REV1/MRD126-REV1.zip

unzip MRD126-REV1.zip

PGCLIENTENCODING=LATIN1 ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=geology \
    -nlt POLYGON -nln on_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/geology/MRD126-REVISION1/MRD126-REV1/ShapeFiles/Geology/Geopoly.shp

rm MRD126-REV1.zip

# US State level via USGS.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table geology.us_geology_attribute(fid serial primary key, unit_link text, lith_rank text, lith1 text, lith2 text, lith3 text, lith4 text, lith5 text, low_lith text, lith_form text, lith_com text);"

wget https://mrdata.usgs.gov/geology/state/shp/IL.zip

unzip IL.zip -d IL

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=geology \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/geology/IL/IL_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/IL/IL_lith.csv' WITH (FORMAT CSV, HEADER)"

rm IL.zip

wget https://mrdata.usgs.gov/geology/state/shp/MN.zip

unzip MN.zip -d MN

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/MN/MN_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/MN/MN_lith.csv' WITH (FORMAT CSV, HEADER)"

rm MN.zip

wget https://mrdata.usgs.gov/geology/state/shp/WI.zip

unzip WI.zip -d WI

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/WI/WI_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/WI/WI_lith.csv' WITH (FORMAT CSV, HEADER)"

rm WI.zip

wget https://mrdata.usgs.gov/geology/state/shp/PA.zip

unzip PA.zip -d PA

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/PA/PA_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/PA/PA_lith.csv' WITH (FORMAT CSV, HEADER)"

rm PA.zip

wget https://mrdata.usgs.gov/geology/state/shp/OH.zip

unzip OH.zip -d OH

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/OH/OH_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/OH/OH_lith.csv' WITH (FORMAT CSV, HEADER)"

rm OH.zip

wget https://mrdata.usgs.gov/geology/state/shp/NY.zip

unzip NY.zip -d NY

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/NY/NY_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/NY/NY_lith.csv' WITH (FORMAT CSV, HEADER)"

rm NY.zip

wget https://mrdata.usgs.gov/geology/state/shp/MI.zip

unzip MI.zip -d MI

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/MI/MI_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/MI/MI_lith.csv' WITH (FORMAT CSV, HEADER)"

rm MI.zip

wget https://mrdata.usgs.gov/geology/state/shp/IN.zip

unzip IN.zip -d IN

ogr2ogr \
    -nlt MULTIPOLYGON -nln us_geology -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=geology" \
    ${DATA_DIR}/geology/IN/IN_geol_poly.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy geology.us_geology_attribute (unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com) FROM '${DATA_DIR}/geology/IN/IN_lith.csv' WITH (FORMAT CSV, HEADER)"

rm IN.zip

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "update geology.us_geology set geom = st_makevalid(geom) where not st_isvalid(geom);"
```

#### Agricultural

```
mkdir ${DATA_DIR}/agriculture; cd ${DATA_DIR}/agriculture

# Canada agg census: https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/

wget https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/CEAG21_Crops_Cultures_REAG21.gdb.zip

unzip CEAG21_Crops_Cultures_REAG21.gdb.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=agriculture \
    -nlt MULTIPOLYGON -nln on_crops -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select * from lccs000b21a_e_ceag21_n where substr(CCSUID, 0, 2) = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/agriculture/CEAG21_Crops_Cultures_REAG21.gdb

rm CEAG21_Crops_Cultures_REAG21.gdb.zip

wget https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/CEAG21_AgriculturalOperations_ExploitationsAgricoles_REAG21.gdb.zip

unzip CEAG21_AgriculturalOperations_ExploitationsAgricoles_REAG21.gdb.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=agriculture \
    -nlt MULTIPOLYGON -nln on_operations -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select * from lccs000b21a_e_ceag21_n where substr(CCSUID, 0, 2) = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/agriculture/CEAG21_AgriculturalOperations_ExploitationsAgricoles_REAG21.gdb

rm CEAG21_AgriculturalOperations_ExploitationsAgricoles_REAG21.gdb.zip

wget https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/CEAG21_FarmOperators_ExploitantsAgricoles_REAG21.gdb.zip

unzip CEAG21_FarmOperators_ExploitantsAgricoles_REAG21.gdb.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=agriculture \
    -nlt MULTIPOLYGON -nln on_operators -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select * from lccs000b21a_e_ceag21_n where substr(CCSUID, 0, 2) = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/agriculture/CEAG21_FarmOperators_ExploitantsAgricoles_REAG21.gdb

rm CEAG21_FarmOperators_ExploitantsAgricoles_REAG21.gdb.zip

wget https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/CEAG21_LivestockPoultryBees_BetailVolailleAbeilles_REAG21.gdb.zip

unzip CEAG21_LivestockPoultryBees_BetailVolailleAbeilles_REAG21.gdb.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=agriculture \
    -nlt MULTIPOLYGON -nln on_livestock -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select * from lccs000b21a_e_ceag21_n where substr(CCSUID, 0, 2) = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/agriculture/CEAG21_LivestockPoultryBees_BetailVolailleAbeilles_REAG21.gdb

rm CEAG21_LivestockPoultryBees_BetailVolailleAbeilles_REAG21.gdb.zip

wget https://ftp.maps.canada.ca/pub/statcan_statcan/Agriculture_Agriculture/census_of_agriculture-recensement_agriculture/2021/CEAG21_UseTenurePractices_UtilisationOccupationPratiques_REAG21.gdb.zip

unzip CEAG21_UseTenurePractices_UtilisationOccupationPratiques_REAG21.gdb.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=agriculture \
    -nlt MULTIPOLYGON -nln on_tenure_practice -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select * from lccs000b21a_e_ceag21_n where substr(CCSUID, 0, 2) = '35'" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    ${DATA_DIR}/agriculture/CEAG21_UseTenurePractices_UtilisationOccupationPratiques_REAG21.gdb

rm CEAG21_UseTenurePractices_UtilisationOccupationPratiques_REAG21.gdb.zip

# US agg census: https://www.nass.usda.gov/Publications/AgCensus/2017/Online_Resources/Ag_Census_Web_Maps/Data_download/index.php

wget https://www.nass.usda.gov/Publications/AgCensus/2017/Online_Resources/Ag_Census_Web_Maps/Data_download/NASSAgcensusDownload2017.xlsx

source ${ENV}/bin/activate

xlsx2csv -n "Variable Lookup" NASSAgcensusDownload2017.xlsx us_variable_lookup.csv

xlsx2csv -n "Crops and Plants" NASSAgcensusDownload2017.xlsx us_crops_and_plants.csv

xlsx2csv -n "Economics" NASSAgcensusDownload2017.xlsx us_economics.csv

xlsx2csv -n "Farms" NASSAgcensusDownload2017.xlsx us_farms.csv

xlsx2csv -n "Livestock and Animals" NASSAgcensusDownload2017.xlsx us_livestock.csv

xlsx2csv -n "Producers" NASSAgcensusDownload2017.xlsx us_producers.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_variable_lookup --unique-constraint 'MapID' us_variable_lookup.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_variable_lookup FROM '${DATA_DIR}/agriculture/us_variable_lookup.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_crops_and_plants --unique-constraint 'FIPS' us_crops_and_plants.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_crops_and_plants FROM '${DATA_DIR}/agriculture/us_crops_and_plants.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_economics --unique-constraint 'FIPS' us_economics.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_economics FROM '${DATA_DIR}/agriculture/us_economics.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_farms --unique-constraint 'FIPS' us_farms.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_farms FROM '${DATA_DIR}/agriculture/us_farms.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_livestock --unique-constraint 'FIPS' us_livestock.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_livestock FROM '${DATA_DIR}/agriculture/us_livestock.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema agriculture --tables us_producers --unique-constraint 'FIPS' us_producers.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy agriculture.us_producers FROM '${DATA_DIR}/agriculture/us_producers.csv' WITH (FORMAT CSV, HEADER)"

# Fix upper class col names.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

\t on
select 'ALTER TABLE '||'agriculture."'||table_name||'"'||' RENAME COLUMN '||'"'||column_name||'"'||' TO ' || lower(column_name)||';' 
from information_schema.columns 
where table_schema = 'agriculture' and lower(column_name) != column_name
\g /tmp/go_to_lower
\i /tmp/go_to_lower

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "CREATE VIEW agriculture.v_us_crops_and_plants_geom as select a.*, geom from agriculture.us_crops_and_plants a join boundary.us_county b on(a.fips::text = b.geoid);"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "CREATE VIEW agriculture.v_us_farms_geom as select a.*, geom from agriculture.us_farms a join boundary.us_county b on(a.fips::text = b.geoid);"
```

#### Conservation authorities: data manually downloaded from client-provided dropbox link. XLSX tables edited to add ID col for matching.

```
cd $DATA_DIR/conservation-authorities

export SHAPE_RESTORE_SHX=YES
first=1
for f in $(find ./SouthON_Streams/OFAT_Watersheds -name *.shp ! -name *._*)
do
    n=$(basename ${f%.*})
    echo $n
    if [ $first -eq 1 ]
    then
        first=0
        ogr2ogr \
            -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=ca_data \
            -nlt POLYGON -nln ofat_watershed -f PostgreSQL -makevalid -s_srs EPSG:3161 -t_srs EPSG:4326 \
            -sql "select *, '${n}' as name from ${n}" \
            PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
            ${f}
    else
        ogr2ogr \
            -nlt POLYGON -nln ofat_watershed -f PostgreSQL -makevalid -s_srs EPSG:3161 -t_srs EPSG:4326 -append \
            -sql "select *, '${n}' as name from ${n}" \
            PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=ca_data" \
            ${f}
    fi
done

source ${ENV}/bin/activate

xlsx2csv -n "Watersheds" ./SouthON_Streams/41Watersheds_LU.xlsx ca_watershed_lookup.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema ca_data --tables ofat_watershed_lookup --unique-constraint 'ID' ca_watershed_lookup.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy ca_data.ofat_watershed_lookup FROM 'ca_watershed_lookup.csv' WITH (FORMAT CSV, HEADER)"

# Fix col names.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

\t on
select 'ALTER TABLE '||'ca_data."'||table_name||'"'||' RENAME COLUMN '||'"'||column_name||'"'||' TO ' || replace(replace(replace(replace(replace(replace(replace(lower(column_name), ' ', '_'), '-', '_'), '/', '_'), '(', ''), ')', ''), '%', 'pcent'), '°', '') ||';' 
from information_schema.columns 
where table_schema = 'ca_data' and lower(column_name) != column_name;
\g /tmp/go_to_lower
\i /tmp/go_to_lower

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table ca_data.ofat_watershed_tkn(id text, watershed text, month text, year int, tkn_mg_l real, tot_precip real, log10_area real, mean_elev_m real, max_elev_m real, mean_slope_pcent real, annual_temperature_c real, community_prop real, ag_prop real, wetland_prop real, treed_prop real)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy ca_data.ofat_watershed_tkn FROM 'TKN_summary.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "DROP VIEW IF EXISTS ca_data.v_ofat_watershed; CREATE VIEW ca_data.v_ofat_watershed as select a.name, watershed_area_km2, watershed_mean_elevation_m, watershed_max_elevation_m, watershed_mean_slope_pcent, length_of_main_channel_km, max_channel_elevation_m, min_channel_elevation_m, slope_of_main_channel_m_km, slope_of_main_channel_pcent, annual_temperature_c, annual_precipitation_mm, community_infrastructure_area, agriculture_and_undifferentiated_rural_land_use_area, open_water_area_km2, shoreline, mudflats, marsh, swamp, fen, bog, heath, sparse_treed, treed_upland, deciduous_treed, mixed_treed, coniferous_treed, plantations_treed_cultivated, hedge_rows, disturbance, open_cliff_and_talus, alvar, sand_barren_and_dune, open_tallgrass_prairie, tallgrass_savannah, tallgrass_woodland, sand_gravel_mine_tailings_extraction, bedrock, a.geom from ca_data.ofat_watershed a left join ca_data.ofat_watershed_lookup b on (b.id = a.name);"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "DROP VIEW IF EXISTS ca_data.v_ofat_watershed_tkn; CREATE VIEW ca_data.v_ofat_watershed_tkn as select distinct a.name, log10_area, community_prop, ag_prop, wetland_prop, treed_prop, a.geom from ca_data.ofat_watershed a left join ca_data.ofat_watershed_tkn b on (b.id = a.name);"
```

#### Nutrients

```
mkdir ${DATA_DIR}/nutrients; cd ${DATA_DIR}/nutrients

# Great Lakes Basin Integrated Nutrient Dataset (2000-2019): https://open.canada.ca/data/en/dataset/8eecfdf5-4fbc-43ec-a504-7e4ee41572eb
wget https://data-donnees.az.ec.gc.ca/api/file?path=/sites%2Fareainterest%2Fgreat-lakes-basin-integrated-nutrient-dataset-2000-2019%2FGreatLakesBasinIntegratedNutrientDataset-2000-2019-v1.csv -O GreatLakesBasinIntegratedNutrientDataset-2000-2019-v1.csv 

wget https://data-donnees.az.ec.gc.ca/api/file?path=/sites%2Fareainterest%2Fgreat-lakes-basin-integrated-nutrient-dataset-2000-2019%2FGreatLakesBasinIntegratedNutrientStations.csv -O GreatLakesBasinIntegratedNutrientStations.csv 

wget https://data-donnees.az.ec.gc.ca/api/file?path=/sites%2Fareainterest%2Fgreat-lakes-basin-integrated-nutrient-dataset-2000-2019%2FStandardizedFields-ChampsStandardiss.csv -O StandardizedFields-ChampsStandardiss.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table nutrient.glbind_nutrient(fid serial primary key, station text, nutrient text, datetime timestamp, value real)"

mlr --csv cut -f Field,Station,Datetime,Value ${DATA_DIR}/nutrients/GreatLakesBasinIntegratedNutrientDataset-2000-2019-v1.csv > GreatLakesBasinIntegratedNutrientDataset-2000-2019-v1_filtered.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy nutrient.glbind_nutrient ( nutrient, station, datetime, value) FROM 'GreatLakesBasinIntegratedNutrientDataset-2000-2019-v1_filtered.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table nutrient.glbind_station(fid serial primary key, source text, station text, location text, latitude real, longitude real)"

mlr --csv cut -f Source,Station,Location,Latitude,Longitude ${DATA_DIR}/nutrients/GreatLakesBasinIntegratedNutrientStations.csv > GreatLakesBasinIntegratedNutrientStations_filtered.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy nutrient.glbind_station (source, station, location, latitude, longitude) FROM 'GreatLakesBasinIntegratedNutrientStations_filtered.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table nutrient.glbind_unit(fid serial primary key, nutrient text, name text, unit text, generalized text)"

cut -d "," -f 1,2,4,5 ${DATA_DIR}/nutrients/StandardizedFields-ChampsStandardiss.csv > StandardizedFields-ChampsStandardiss_filtered.csv

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy nutrient.glbind_unit (nutrient, name, unit, generalized) FROM 'StandardizedFields-ChampsStandardiss_filtered.csv' WITH (FORMAT CSV, HEADER, ENCODING 'LATIN1')"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "
drop view if exists nutrient.v_glbind_latest_nutrient;

create view nutrient.v_glbind_latest_nutrient as (
    with tn_max_times as (
        select station, max(datetime) as max_time
        from nutrient.glbind_nutrient gn
        where nutrient = 'TN'
        group by station
    ),

    tp_max_times as (
        select station, max(datetime) as max_time
        from nutrient.glbind_nutrient gn
        where nutrient = 'TP'
        group by station
    ),

    tn_vals as (
        select gn.station, avg(value) as total_nitrogen_mg_l
        from nutrient.glbind_nutrient gn
        join tn_max_times mt on (mt.station = gn.station and mt.max_time = gn.datetime)
        where nutrient = 'TN'
        group by gn.station
    ),

    tp_vals as (
        select gn.station, avg(value) as total_phosphorus_mg_l
        from nutrient.glbind_nutrient gn
        join tp_max_times mt on (mt.station = gn.station and mt.max_time = gn.datetime)
        where nutrient = 'TP'
        group by gn.station
    )

    select source, gs.station, location, total_nitrogen_mg_l, total_phosphorus_mg_l, st_point(longitude, latitude, 4326) as geom

    from nutrient.glbind_station gs

    left join tn_vals n on (n.station = gs.station)

    left join tp_vals p on (p.station = gs.station)
);"

# SPARROW model results: https://www.arcgis.com/apps/MapSeries/index.html?appid=d41a2e7273d041d2b496623aa10daa25
wget https://sparrow.wim.usgs.gov/midcontinent-2002/downloads/midcont_shapefiles_phosphorus.zip

wget https://sparrow.wim.usgs.gov/midcontinent-2002/downloads/midcont_shapefiles_nitrogen.zip

find *.zip -exec unzip {} \;

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=nutrient \
    -nlt MULTIPOLYGON -nln sparrow_phosphorus -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select SPARROWID_ as sparrow_id, STRM_NAME as stream_name, gp1 as major_drainage_area, gp2 as tributary, gp3 as hu8_catchment, accl as accumulated_load_kg, incl as incremental_load_kg, accy as accumulated_yield_kg_km2, incy as incremental_yield_kg_km2, daccl as delivered_accumulated_load_kg, daccy as delivered_accumulated_yield_kg_km2, dincl as delivered_incremental_load_kg, dincy as delivered_incremental_yield_kg_km2 from midcont_cats_tp" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    midcont_shapefiles_phosphorus/midcont_cats_tp.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "update nutrient.sparrow_phosphorus set geom = st_makevalid(geom) where not st_isvalid(geom);"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=nutrient \
    -nlt MULTIPOLYGON -nln sparrow_nitrogen -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select SPARROWID_ as sparrow_id, STRM_NAME as stream_name, gp1 as major_drainage_area, gp2 as tributary, gp3 as hu8_catchment, accl as accumulated_load_kg, incl as incremental_load_kg, accy as accumulated_yield_kg_km2, incy as incremental_yield_kg_km2, daccl as delivered_accumulated_load_kg, daccy as delivered_accumulated_yield_kg_km2, dincl as delivered_incremental_load_kg, dincy as delivered_incremental_yield_kg_km2 from midcont_cats_tn" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    midcont_shapefiles_nitrogen/midcont_cats_tn.shp

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "update nutrient.sparrow_nitrogen set geom = st_makevalid(geom) where not st_isvalid(geom);"

rm *.zip
```

#### Mines

```
mkdir -p $DATA_DIR/mines; cd $DATA_DIR/mines

# Geology Ontario abandoned mines: https://www.hub.geologyontario.mines.gov.on.ca/
wget https://www.geologyontario.mndm.gov.on.ca/mines/ogs/databases/AMIS_2022_04.zip

unzip AMIS_2022_04.zip

rm AMIS_2022_04.zip

source ${ENV}/bin/activate

xlsx2csv -n "AMIS_SITES_APR2022" ./AMIS_2022_04/EXCEL_spreadsheets/AMIS_SITES_APR2022.xlsx amis_sites.csv

ogr2ogr -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=mine \
    -nlt POINT -nln amis_mine -f PostgreSQL -makevalid -a_srs EPSG:4326 \
    -oo X_POSSIBLE_NAMES=LONGITUDE -oo Y_POSSIBLE_NAMES=LATITUDE -oo KEEP_GEOM_COLUMNS=NO \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    amis_sites.csv

# Fix col names.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

DO $$
DECLARE
  row record;
BEGIN
    FOR row IN
        SELECT column_name
        FROM
            information_schema.columns
        WHERE
            table_schema = 'mine' AND table_name = 'amis_mine' AND column_name LIKE '% %' LOOP

        EXECUTE 'ALTER TABLE mine.amis_mine RENAME "' || row.column_name || '" TO "' || REPLACE(row.column_name , ' ', '_') || '";';
    END LOOP;
END;

# Canvec resource management: https://open.canada.ca/data/en/dataset/92dbea79-f644-4a62-b25e-8eb993ca0264
wget https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/fgdb/Res_MGT/canvec_50K_ON_Res_MGT_fgdb.zip

unzip canvec_50K_ON_Res_MGT_fgdb.zip 

rm canvec_50K_ON_Res_MGT_fgdb.zip

ogr2ogr -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=mine \
    -nlt MULTIPOLYGON -nln canvec_extraction_site -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select 'ore' as site_type from ore_2" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Res_MGT.gdb

ogr2ogr -nlt MULTIPOLYGON -nln canvec_extraction_site -f PostgreSQL -makevalid -t_srs EPSG:4326 -append \
    -sql "select 'aggregate' as site_type from aggregate_2" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD} schemas=mine" \
    canvec_50K_ON_Res_MGT.gdb
```

#### Export vector tiles.

```
mkdir -p $DATA_DIR/served/mbtiles

cd $DATA_DIR/served/mbtiles


# Agriculture
ogr2ogr -sql "select ccsuid, ccsname, tfarea_m as farmed_area_ha, geom from agriculture.on_tenure_practice" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o on_farm_area.mbtiles --name on_farm_area

ogr2ogr -sql "select fips, y17_m059_valuenumeric as farmed_area_percent, geom from agriculture.v_us_farms_geom" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o us_farm_area.mbtiles --name us_farm_area

tile-join -f -o agriculture.mbtiles on_farm_area.mbtiles us_farm_area.mbtiles


# Bathymetry
ogr2ogr -sql "select depth, geom from bathymetry.contour" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce -o bathymetry_contour.mbtiles --name bathymetry_contour


# Boundary
ogr2ogr -sql "select name, geom from boundary.ontario union all select name, geom from boundary.us_state" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o adm2.mbtiles --name adm2

ogr2ogr -sql "select name, geom from boundary.on_census_division" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o on_census_division.mbtiles --name on_census_division

ogr2ogr -sql "select name, geom from boundary.on_census_subdivision" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o on_census_subdivision.mbtiles --name on_census_subdivision

ogr2ogr -sql "select name, geom from boundary.on_census_consolidated_subdivision" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o on_census_consolidated_subdivision.mbtiles --name on_census_consolidated_subdivision

ogr2ogr -sql "select name, geom from boundary.us_county" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o us_county.mbtiles --name us_county

ogr2ogr -sql "select name, geom from boundary.us_tract" \
    -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o us_tract.mbtiles --name us_tract

tile-join -f -o boundary.mbtiles adm2.mbtiles on_census_division.mbtiles on_census_subdivision.mbtiles on_census_consolidated_subdivision.mbtiles us_county.mbtiles us_tract.mbtiles


# Conservation authority data
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" ca_data.v_ofat_watershed \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o ca_watershed_lookup.mbtiles --name ca_watershed

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" ca_data.v_ofat_watershed_tkn \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o ca_watershed_tkn.mbtiles --name ca_watershed_tkn

tile-join -f -pk -o ca_watershed.mbtiles ca_watershed_lookup.mbtiles ca_watershed_tkn.mbtiles


# Geology
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select unit_link, generalize as rock_type, geom from geology.us_geology" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o us_geology.mbtiles --name us_geology

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select unitname_p as unit_name, rocktype_p as rock_type, strat_p as strat, geom from geology.on_geology" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-densest-as-needed -o on_geology.mbtiles --name on_geology

tile-join -f -pk -o geology.mbtiles us_geology.mbtiles on_geology.mbtiles


# Nutrients
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" nutrient.sparrow_nitrogen \
    | tippecanoe -z 12 --force --detect-shared-borders --simplification 10 --coalesce-densest-as-needed --coalesce-smallest-as-needed \
    --accumulate-attribute=accumulated_load_kg:sum --accumulate-attribute=incremental_load_kg:sum --accumulate-attribute=accumulated_yield_kg_km2:sum --accumulate-attribute=incremental_yield_kg_km2:sum --accumulate-attribute=delivered_accumulated_load_kg:sum --accumulate-attribute=delivered_accumulated_yield_kg_km2:sum --accumulate-attribute=delivered_incremental_load_kg:sum --accumulate-attribute=delivered_incremental_yield_kg_km2:sum \
    -o sparrow_nitrogen.mbtiles --name sparrow_nitrogen

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" nutrient.sparrow_phosphorus \
    | tippecanoe -z 12 --force --detect-shared-borders --simplification 10 --coalesce-densest-as-needed --coalesce-smallest-as-needed \
    --accumulate-attribute=accumulated_load_kg:sum --accumulate-attribute=incremental_load_kg:sum --accumulate-attribute=accumulated_yield_kg_km2:sum --accumulate-attribute=incremental_yield_kg_km2:sum --accumulate-attribute=delivered_accumulated_load_kg:sum --accumulate-attribute=delivered_accumulated_yield_kg_km2:sum --accumulate-attribute=delivered_incremental_load_kg:sum --accumulate-attribute=delivered_incremental_yield_kg_km2:sum \
    -o sparrow_phosphorus.mbtiles --name sparrow_phosphorus

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" nutrient.v_glbind_latest_nutrient \
    | tippecanoe -B 6 -z 12 --force -o glbind_latest_nutrient.mbtiles --name glbind_latest_nutrient

tile-join -f -pk -o nutrient.mbtiles sparrow_nitrogen.mbtiles sparrow_phosphorus.mbtiles glbind_latest_nutrient.mbtiles


# Waterbody
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select description as type, name, geom from waterbody.nhd_waterbody wb join watercourse.nhd_fcode fc on (wb.type = fc.fcode)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --detect-shared-borders --simplification 10 --coalesce-densest-as-needed --coalesce-smallest-as-needed --drop-smallest-as-needed -o us_waterbody.mbtiles --name us_waterbody

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select type, name, geom from waterbody.ohn_waterbody" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --detect-shared-borders --simplification 10 --coalesce-densest-as-needed --coalesce-smallest-as-needed --drop-smallest-as-needed -o on_waterbody.mbtiles --name on_waterbody

tile-join -f -pk -o waterbody.mbtiles us_waterbody.mbtiles on_waterbody.mbtiles


# Watercourse
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select description as type, name, geom from watercourse.nhd_flowline fl join watercourse.nhd_fcode fc on (fl.type = fc.fcode) where type in (46000, 46006, 46003, 33600, 33603)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce -o us_watercourse.mbtiles --name us_watercourse

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson \
    -sql "select type, name, geom from watercourse.ohn_watercourse where type in ('Ditch', 'Stream')" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce -o on_watercourse.mbtiles --name on_watercourse

tile-join -f -pk -o watercourse.mbtiles us_watercourse.mbtiles on_watercourse.mbtiles


# Watersheds
for l in owb_primary owb_secondary owb_tertiary owb_quaternary
do
    ogr2ogr -sql "select watershed_name, watershed_code, geom from watershed.${l}" \
        -f GeoJSON ${DATA_DIR}/served/geojson/.geojson PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
        | tippecanoe -z 12 --force --coalesce-densest-as-needed -o ${l}.mbtiles --name ${l}
done

rm -R watershed.mbtiles

tile-join -o watershed.mbtiles owb_primary.mbtiles owb_secondary.mbtiles owb_tertiary.mbtiles owb_quaternary.mbtiles


# Wetlands
ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson -sql "select type, geom from wetland.on_wetland" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-smallest-as-needed -o on_wetland.mbtiles --name on_wetland

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/.geojson -sql "select type, geom from wetland.us_wetland" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-smallest-as-needed -o us_wetland.mbtiles --name us_wetland

tile-join -f -pk -o wetland.mbtiles on_wetland.mbtiles us_wetland.mbtiles


# Mines
ogr2ogr -f GeoJSON /dev/stdout -sql "select * from mine.amis_mine" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -B 8 -z 12 --force -o amis_mine.mbtiles --name amis_mine

ogr2ogr -f GeoJSON /dev/stdout -sql "select site_type, geom from mine.canvec_extraction_site" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -z 12 --force --coalesce-smallest-as-needed -o canvec_extraction_site.mbtiles --name canvec_extraction_site

tile-join -f -pk -o mines.mbtiles amis_mine.mbtiles canvec_extraction_site.mbtiles
```

#### Export csv tables.

```
mkdir -p $DATA_DIR/served/csv

cd $DATA_DIR/served/csv

# CA watershed TKN time series data.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select id, month, year, tkn_mg_l, tot_precip from ca_data.ofat_watershed_tkn) to 'ca_data_ofat_watershed_tkn_ts.csv' csv header"

# US Geology.
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select unit_link, lith_rank, lith1, lith2, lith3, lith4, lith5, low_lith, lith_form, lith_com from geology.us_geology_attribute) to 'us_geology_attribute.csv' csv header"
```

#### Export raster tiles.

```
mkdir ${DATA_DIR}/served/raster-tiles


# Elev
gdal_translate -of VRT -ot Byte -scale ${DATA_DIR}/srtm/srtm.tif ${DATA_DIR}/srtm/elev.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 4-12 --processes 4 ${DATA_DIR}/srtm/elev.vrt ${DATA_DIR}/served/raster-tiles/elev

mb-util ${DATA_DIR}/served/raster-tiles/elev ${DATA_DIR}/served/mbtiles/elev.mbtiles

gdal_translate -of VRT -ot Byte -scale ${DATA_DIR}/srtm/hillshade.tif ${DATA_DIR}/srtm/hillshade.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 4-12 --processes 4 ${DATA_DIR}/srtm/hillshade.vrt ${DATA_DIR}/served/raster-tiles/hillshade

mb-util ${DATA_DIR}/served/raster-tiles/hillshade ${DATA_DIR}/served/mbtiles/hillshade.mbtiles

gdal_translate -of VRT -ot Byte -scale ${DATA_DIR}/srtm/slope.tif ${DATA_DIR}/srtm/slope.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 4-12 --processes 4 ${DATA_DIR}/srtm/slope.vrt ${DATA_DIR}/served/raster-tiles/slope

mb-util ${DATA_DIR}/served/raster-tiles/slope ${DATA_DIR}/served/mbtiles/slope.mbtiles

gdal_translate -of vrt -expand rgba ${DATA_DIR}/land-cover/landcover_2020_clipped.tif ${DATA_DIR}/land-cover/landcover_2020_clipped.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 4-12 --processes 4 ${DATA_DIR}/land-cover/landcover_2020_clipped.vrt ${DATA_DIR}/served/raster-tiles/land-cover


# Bathymetry
gdal_translate -of VRT -ot Byte -scale ${DATA_DIR}/bathymetry/great_lakes.tif ${DATA_DIR}/bathymetry/great_lakes.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 4-12 --processes 4 ${DATA_DIR}/bathymetry/great_lakes.vrt ${DATA_DIR}/served/raster-tiles/bathymetry

mb-util ${DATA_DIR}/served/raster-tiles/bathymetry ${DATA_DIR}/served/mbtiles/bathymetry.mbtiles


# Land cover
mb-util ${DATA_DIR}/served/raster-tiles/land-cover ${DATA_DIR}/served/mbtiles/land_cover.mbtiles
```


### MODULE B

#### Additional data download and import

```
# Canvec map layers for ON: https://open.canada.ca/data/en/dataset/8ba2aa2a-7bb9-4448-b4d7-f164409fe056

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema canvec;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema canvec TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema canvec grant select on tables to ${READ_ONLY_USER};"

mkdir ${DATA_DIR}/canvec; cd ${DATA_DIR}/canvec

wget https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/fgdb/Hydro/canvec_50K_ON_Hydro_fgdb.zip

wget https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/fgdb/Land/canvec_50K_ON_Land_fgdb.zip

wget https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/fgdb/Toponymy/canvec_50K_ON_Toponymy_fgdb.zip

wget https://ftp.maps.canada.ca/pub/nrcan_rncan/vector/canvec/fgdb/Transport/canvec_50K_ON_Transport_fgdb.zip

find . -name "*.zip" -exec unzip {} \; -exec /bin/rm {} \;

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nlt MULTIPOLYGON -nln wetland -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, saturated_soil_descriptor from saturated_soil_2" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Land.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_wetland_feature_id on canvec.wetland (feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_wetland_saturated_soil_descriptor on canvec.wetland (saturated_soil_descriptor)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nlt MULTIPOLYGON -nln woodland -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, wood_coverage_descriptor from wooded_area_2" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Land.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_woodland_feature_id on canvec.woodland(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_woodland_wood_coverage_descriptor on canvec.woodland (wood_coverage_descriptor)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nlt MULTIPOLYGON -nln waterbody -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, water_definition, permanency, name_en, name_fr from waterbody_2" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Hydro.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_waterbody_feature_id on canvec.waterbody(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_waterbody_water_definition on canvec.waterbody(water_definition)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nln watercourse -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, water_definition, permanency, name_en, name_fr from watercourse_1" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Hydro.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_watercourse_feature_id on canvec.watercourse(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_watercourse_water_definition on canvec.watercourse(water_definition)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nln label -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, named_feature_descriptor, display_scale, display_priority, name_en, name_fr from bdg_named_feature_0 where active_toponym = 11" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Toponymy.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_label_feature_id on canvec.label(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_label_named_feature_descriptor on canvec.label(named_feature_descriptor)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_label_display_scale on canvec.label(display_scale)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_label_display_priority on canvec.label(display_priority)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nln trail -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id from trail_1" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Transport.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_trail_feature_id on canvec.trail(feature_id)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nln railway -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, track_classification from track_segment_1" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Transport.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_railway_feature_id on canvec.railway(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_railway_track_classification on canvec.railway(track_classification)"

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=canvec \
    -nln road -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select feature_id, road_class from road_segment_1" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    canvec_50K_ON_Transport.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_road_feature_id on canvec.road(feature_id)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index canvec_road_road_class on canvec.road(road_class)"

# Extract and import field domain tables from gdbs.
domainsScript=${SCRIPTS}/exportFGDBFieldDomains.py

for t in saturated_soil_descriptor wood_coverage_descriptor
do
    python3 ${domainsScript} canvec_50K_ON_Land.gdb -t ${t}_cl -o ${t}.csv

    mlr --csv cut -f key,description ${t}.csv > ${t}_clipped.csv

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "drop table if exists canvec.${t}_lookup; create table canvec.${t}_lookup(key int primary key, description text);"

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy canvec.${t}_lookup(key, description) FROM '${t}_clipped.csv' WITH (FORMAT CSV, HEADER)"
done

for t in water_definition permanency
do
    python3 ${domainsScript} canvec_50K_ON_Hydro.gdb -t ${t}_cl -o ${t}.csv

    mlr --csv cut -f key,description ${t}.csv > ${t}_clipped.csv

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "drop table if exists canvec.${t}_lookup; create table canvec.${t}_lookup(key int primary key, description text);"

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy canvec.${t}_lookup(key, description) FROM '${t}_clipped.csv' WITH (FORMAT CSV, HEADER)"
done

for t in named_feature_descriptor display_scale
do
    python3 ${domainsScript} canvec_50K_ON_Toponymy.gdb -t ${t}_cl -o ${t}.csv

    mlr --csv cut -f key,description ${t}.csv > ${t}_clipped.csv

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "drop table if exists canvec.${t}_lookup; create table canvec.${t}_lookup(key int primary key, description text);"

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy canvec.${t}_lookup(key, description) FROM '${t}_clipped.csv' WITH (FORMAT CSV, HEADER)"
done

for t in track_classification road_class
do
    python3 ${domainsScript} canvec_50K_ON_Transport.gdb -t ${t}_cl -o ${t}.csv

    mlr --csv cut -f key,description ${t}.csv > ${t}_clipped.csv

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "drop table if exists canvec.${t}_lookup; create table canvec.${t}_lookup(key int primary key, description text);"

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy canvec.${t}_lookup(key, description) FROM '${t}_clipped.csv' WITH (FORMAT CSV, HEADER)"
done


# Statistics Canada census 2021 population centres: https://www12.statcan.gc.ca/census-recensement/2021/dp-pd/index-eng.cfm

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema census_2021;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema census_2021 TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema census_2021 grant select on tables to ${READ_ONLY_USER};"

mkdir ${DATA_DIR}/statistics-canada; cd ${DATA_DIR}/statistics-canada

wget https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/files-fichiers/lpc_000a21f_e.zip

unzip lpc_000a21f_e.zip; rm lpc_000a21f_e.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=census_2021 \
    -nlt MultiPolygon -nln population_centre -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    -sql "select PCNAME as name, PCTYPE as type, PCCLASS as class from lpc_000a21f_e" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    lpc_000a21f_e.gdb

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index census_2021_population_centre_type on census_2021.population_centre (type)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create index census_2021_population_centre_class on census_2021.population_centre (class)"


# ON provincial DEM: https://geohub.lio.gov.on.ca/maps/mnrf::provincial-digital-elevation-model-pdem/about

mkdir ${DATA_DIR}/onmnrf; cd ${DATA_DIR}/onmnrf;

wget https://ws.gisetl.lrc.gov.on.ca/fmedatadownload/Packages/PDEM-South-D2013.zip

unzip PDEM-South-D2013.zip; rm PDEM-South-D2013.zip

gdaldem hillshade ${DATA_DIR}/onmnrf/PDEM_South.tif ${DATA_DIR}/onmnrf/hillshade.tif


# HYDAT database: https://www.canada.ca/en/environment-climate-change/services/water-overview/quantity/monitoring/survey/data-products-services/national-archive-hydat.html

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema hydat;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema hydat TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema hydat grant select on tables to ${READ_ONLY_USER};"

mkdir ${DATA_DIR}/hydat; cd ${DATA_DIR}/hydat

wget https://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/Hydat_sqlite3_20240116.zip

unzip Hydat_sqlite3_20240116.zip

rm Hydat_sqlite3_20240116.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=hydat \
    -nlt POINT -nln station -f PostgreSQL -a_srs EPSG:4326 \
    -sql "select *, MakePoint(longitude, latitude, 4326) as geom from stations" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    Hydat.sqlite3

sqlite3 Hydat.sqlite3

.headers on
.mode csv
.output daily_flows.csv
SELECT * FROM DLY_FLOWS;

.output daily_levels.csv
SELECT * FROM DLY_LEVELS;

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema hydat --tables daily_flow daily_flows.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy hydat.daily_flow FROM 'daily_flows.csv' WITH (FORMAT CSV, HEADER)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "$(csvsql --db-schema hydat --tables daily_level daily_levels.csv)"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy hydat.daily_level FROM 'daily_levels.csv' WITH (FORMAT CSV, HEADER)"

# Fix col names
psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER}

DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'hydat' AND 
                           table_name   = 'daily_flow'
  LOOP
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));  
  END LOOP;
END $$;

DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'hydat' AND 
                           table_name   = 'daily_level'
  LOOP
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));  
  END LOOP;
END $$;

# ON Soil survey Complex: https://geohub.lio.gov.on.ca/datasets/ontarioca11::soil-survey-complex/about

mkdir ${DATA_DIR}/soil; cd ${DATA_DIR}/soil

wget https://www.gisapplication.lrc.gov.on.ca/fmedatadownload/Packages/fgdb/SOILOMAF.zip

unzip SOILOMAF.zip; rm SOILOMAF.zip

ogr2ogr \
    -lco OVERWRITE=TRUE -lco GEOMETRY_NAME=geom -lco FID=fid -lco SCHEMA=soil \
    -nlt MULTIPOLYGON -nln soil_complex -f PostgreSQL -makevalid -t_srs EPSG:4326 \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    Non_Sensitive.gdb SOIL_SURVEY_COMPLEX


### Clip layers to Thames watershed

mkdir -p ${DATA_DIR}/thames-watershed

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create schema thames_watershed;"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "grant usage on schema thames_watershed TO ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "alter default privileges in schema thames_watershed grant select on tables to ${READ_ONLY_USER};"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "create table thames_watershed.ofat_watershed as select * from ca_data.ofat_watershed where name = 'Thames_R'"

for LYR in boundary.on_census_subdivision boundary.on_census_division canvec.label canvec.railway canvec.road canvec.trail canvec.waterbody canvec.watercourse canvec.wetland canvec.woodland census_2021.population_centre geology.on_geology nutrient.sparrow_nitrogen nutrient.sparrow_phosphorus watershed.owb_quaternary watershed.owb_tertiary hydat.station soil.soil_complex mine.canvec_extraction_site
do
    IFS='.' read -ra ARR <<< "${LYR}"
    SCHEMA=${ARR[0]}
    TABLE=${ARR[1]}
    COLS=($(psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -t -c "
        SELECT column_name
        FROM information_schema.columns
        where table_schema = '${SCHEMA}'
        and table_name = '${TABLE}'
        and column_name != 'geom';
    "))
    COLS=$(IFS=, ; echo "${COLS[*]}")

    psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -t -c "
        drop table if exists thames_watershed.${TABLE};
        create table thames_watershed.${TABLE} as
        select ${COLS}, st_intersection(l.geom, w.geom) as geom
        from (select geom from thames_watershed.ofat_watershed) w
        join ${LYR} l on st_intersects(l.geom, w.geom);
    "
done

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -t -c "
    drop table if exists thames_watershed.${TABLE};
    create table thames_watershed.glbind_station as
    select fid, source, station, location, st_point(longitude, latitude, 4326) as geom
    from (select geom from thames_watershed.ofat_watershed) w
    join nutrient.glbind_station l on st_intersects(st_point(longitude, latitude, 4326), w.geom);
"

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl thames_watershed.ofat_watershed -crop_to_cutline \
    ${DATA_DIR}/onmnrf/PDEM_South.tif \
    ${DATA_DIR}/thames-watershed/elev.tif

# Create color relief map: 172-421
gdalinfo ${DATA_DIR}/thames-watershed/elev.tif -mm

nano ${DATA_DIR}/thames-watershed/color_relief.txt

0 255 255 255 0
150 2 124 30 255
175 70 137 40 255
200 105 149 54 255
225 134 160 71 255
250 159 170 90 255
275 181 180 109 255
300 201 189 130 255
325 218 197 150 255
350 231 205 170 255
375 241 213 191 255
400 242 218 206 255
425 226 226 226 255

gdaldem \
    color-relief -alpha \
    ${DATA_DIR}/thames-watershed/elev.tif \
    ${DATA_DIR}/thames-watershed/color_relief.txt \
    ${DATA_DIR}/thames-watershed/color_relief.tif

gdalwarp \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl thames_watershed.ofat_watershed -crop_to_cutline \
    ${DATA_DIR}/onmnrf/hillshade.tif \
    ${DATA_DIR}/thames-watershed/hillshade.tif

gdalwarp \
    -t_srs EPSG:3347 -tr 30 30 \
    -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES -co COMPRESS=LZW -co TILED=YES -overwrite \
    -cutline PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" -cl thames_watershed.ofat_watershed -crop_to_cutline \
    ${DATA_DIR}/land-cover/land_cover_2020_30m_tif/NA_NALCMS_landcover_2020_30m/data/NA_NALCMS_landcover_2020_30m.tif \
    ${DATA_DIR}/thames-watershed/landcover_2020_clipped.tif
```

#### Create basemap layers, served from the tile server as png iamges.

```
# Cartographic basemap layers.

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select description, geom from thames_watershed.railway lyr join canvec.track_classification_lookup lk on (lk.key = lyr.track_classification)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_railway.mbtiles --name thames_watershed_railway

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select description, geom from thames_watershed.road lyr join canvec.road_class_lookup lk on (lk.key = lyr.road_class)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_road.mbtiles --name thames_watershed_road

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select geom from thames_watershed.trail" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_trail.mbtiles --name thames_watershed_trail

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select name_en, description, geom from thames_watershed.waterbody lyr join canvec.water_definition_lookup lk on (lk.key = lyr.water_definition)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_waterbody.mbtiles --name thames_watershed_waterbody

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select name_en, description, geom from thames_watershed.watercourse lyr join canvec.water_definition_lookup lk on (lk.key = lyr.water_definition)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_watercourse.mbtiles --name thames_watershed_watercourse

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select description, geom from thames_watershed.wetland lyr join canvec.saturated_soil_descriptor_lookup lk on (lk.key = lyr.saturated_soil_descriptor)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_wetland.mbtiles --name thames_watershed_wetland

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select description, geom from thames_watershed.woodland lyr join canvec.wood_coverage_descriptor_lookup lk on (lk.key = lyr.wood_coverage_descriptor)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_woodland.mbtiles --name thames_watershed_woodland

ogr2ogr -f GeoJSON /dev/stdout \
    -sql "select name, class, geom from thames_watershed.population_centre" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" \
    | tippecanoe -Z 7 -z 14 --force --coalesce -o ${DATA_DIR}/served/mbtiles/thames_watershed_population_centre.mbtiles --name thames_watershed_population_centre

tile-join -f -pk -o ${DATA_DIR}/served/mbtiles/thames_watershed_cartographic.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_railway.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_road.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_trail.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_waterbody.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_watercourse.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_wetland.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_woodland.mbtiles \
    ${DATA_DIR}/served/mbtiles/thames_watershed_population_centre.mbtiles

# Raster basemap layers.

gdal2tiles.py -e -xyz -w none --zoom 7-14 --processes 4 ${DATA_DIR}/thames-watershed/color_relief.tif ${DATA_DIR}/served/raster-tiles/thames-watershed-elev

rm ${DATA_DIR}/served/mbtiles/thames-watershed-elev.mbtiles

mb-util ${DATA_DIR}/served/raster-tiles/thames-watershed-elev ${DATA_DIR}/served/mbtiles/thames-watershed-elev.mbtiles

gdal_translate -of VRT -ot Byte -scale ${DATA_DIR}/thames-watershed/hillshade.tif ${DATA_DIR}/thames-watershed/hillshade.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 7-14 --processes 4 ${DATA_DIR}/thames-watershed/hillshade.vrt ${DATA_DIR}/served/raster-tiles/thames-watershed-hillshade

rm ${DATA_DIR}/served/mbtiles/thames-watershed-hillshade.mbtiles

mb-util ${DATA_DIR}/served/raster-tiles/thames-watershed-hillshade ${DATA_DIR}/served/mbtiles/thames-watershed-hillshade.mbtiles

gdal_translate -of vrt -expand rgba ${DATA_DIR}/thames-watershed/landcover_2020_clipped.tif ${DATA_DIR}/thames-watershed/landcover_2020_clipped.vrt

gdal2tiles.py -e -x --xyz -w none --zoom 7-14 --processes 4 ${DATA_DIR}/thames-watershed/landcover_2020_clipped.vrt ${DATA_DIR}/served/raster-tiles/thames-watershed-land-cover

rm ${DATA_DIR}/served/mbtiles/thames-watershed-land-cover.mbtiles

mb-util ${DATA_DIR}/served/raster-tiles/thames-watershed-land-cover ${DATA_DIR}/served/mbtiles/thames-watershed-land-cover.mbtiles
```

#### Create geojson files for leaflet map.

```
mkdir ${DATA_DIR}/served/geojson

# Contextual/overlay layers.

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_ofat_watershed.geojson \
    -sql "select geom from thames_watershed.ofat_watershed" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}" 

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_owb_tertiary.geojson \
    -sql "select watershed_code, watershed_name, geom from thames_watershed.owb_tertiary" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_owb_quaternary.geojson \
    -sql "select watershed_code, watershed_name, geom from thames_watershed.owb_quaternary" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_census_subdivision.geojson \
    -sql "select name, geom from thames_watershed.on_census_subdivision" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_census_division.geojson \
    -sql "select name, geom from thames_watershed.on_census_division" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_label_low_zoom.geojson \
    -sql "select name_en, geom from thames_watershed.label where named_feature_descriptor in (912, 951)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_label_high_zoom.geojson \
    -sql "select name_en, geom from thames_watershed.label where named_feature_descriptor in (912, 951, 956, 920, 952)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_canvec_extraction_site.geojson \
    -sql "select * from thames_watershed.canvec_extraction_site" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"


# Scientific feature layers and matching csv tables.

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_glbind_station.geojson \
    -sql "select source, station, location, geom from thames_watershed.glbind_station" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_hydat_station.geojson \
    -sql "select station_number, station_name, geom from thames_watershed.station" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_geology.geojson \
    -sql "select rocktype_p, strat_p, eon_p, era_p, period_p, epoch_p, geom from thames_watershed.on_geology" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_soil.geojson \
    -sql "select mapunit, percent1, soiltype1, soilcode1, soil_name1, symbol1, parnt_mat1, landscape1, slope1, class1, range1, stoniness1, cli1, cli1_1, cli1_2, survey1, drainage1, dr_design1, hydro1, atexture1, modifier1, k_factor1, percent2, soiltype2, soilcode2, soil_name2, symbol2, parnt_mat2, landscape2, slope2, class2, range2, stoniness2, cli2, cli2_1, cli2_2, survey2, drainage2, dr_design2, hydro2, atexture2, modifier2, k_factor2, percent3, soiltype3, soilcode3, soil_name3, symbol3, parnt_mat3, landscape3, slope3, class3, range3, stoniness3, cli3, cli3_1, cli3_2, survey3, drainage3, dr_design3, hydro3, atexture3, modifier3, k_factor3, geom from thames_watershed.soil_complex" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

ogr2ogr -f GeoJSON ${DATA_DIR}/served/geojson/thames_watershed_sparrow.geojson \
    -sql "select p.major_drainage_area, p.tributary, p.hu8_catchment, p.accumulated_load_kg as p_accumulated_load_kg, p.incremental_load_kg as p_incremental_load_kg, p.accumulated_yield_kg_km2 as p_accumulated_yield_kg_km2, p.incremental_yield_kg_km2 as p_incremental_yield_kg_km2, p.delivered_accumulated_yield_kg_km2 as p_delivered_accumulated_yield_kg_km2, p.delivered_incremental_load_kg as p_delivered_incremental_load_kg, p.delivered_incremental_yield_kg_km2 as p_delivered_incremental_yield_kg_km2, n.accumulated_load_kg as n_accumulated_load_kg, n.incremental_load_kg as n_incremental_load_kg, n.accumulated_yield_kg_km2 as n_accumulated_yield_kg_km2, n.incremental_yield_kg_km2 as n_incremental_yield_kg_km2, n.delivered_accumulated_yield_kg_km2 as n_delivered_accumulated_yield_kg_km2, n.delivered_incremental_load_kg as n_delivered_incremental_load_kg, n.delivered_incremental_yield_kg_km2 as n_delivered_incremental_yield_kg_km2, p.geom from thames_watershed.sparrow_phosphorus p join thames_watershed.sparrow_nitrogen n on (p.sparrow_id = n.sparrow_id)" \
    PG:"host=${DB_HOST} port=${DB_PORT} user=${DB_USER} dbname=${DB} password=${DB_PASSWORD}"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select station, nutrient, datetime, value from nutrient.glbind_nutrient where station in (select station from thames_watershed.glbind_station)) to '${DATA_DIR}/served/csv/thames_watershed_glbind_ts.csv' csv header"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select nutrient, name, unit, generalized from nutrient.glbind_unit where nutrient in (select distinct nutrient from nutrient.glbind_nutrient where station in (select station from thames_watershed.glbind_station))) to '${DATA_DIR}/served/csv/thames_watershed_glbind_unit.csv' csv header"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select station_number, year, month, monthly_mean, min, max from hydat.daily_flow where station_number in (select distinct station_number from thames_watershed.station)) to '${DATA_DIR}/served/csv/thames_watershed_hydat_monthly_flow.csv' csv header"

psql -h ${DB_HOST} -p ${DB_PORT} -d ${DB} -U ${DB_USER} -c "\copy (select station_number, year, month, monthly_mean, min, max from hydat.daily_level where station_number in (select distinct station_number from thames_watershed.station)) to '${DATA_DIR}/served/csv/thames_watershed_hydat_monthly_level.csv' csv header"


# Conservation Area station water temperature records: https://data-cwdv.ca/applications/public.html?publicuser=Public#cwdv/stationoverview
Draw on map > Table > Time series > Select up to 9 stations at a time for chosen var (water temp) > Graph > Set date range to 1 year > Download as csv & Manually edit in Excel, retaining station_no, timestamp, and value columns - saved as "upper_thames_ts.csv"

Station coordinates extracted and exported to geojson via QGIS as "upper_thames_stations.geojson"
```
