#!/bin/bash
#https://gitea.typename.fr/INSA/be-graphes-map-generator/src/branch/master/inputs/coastline-fix.sh

#NEEDED! pip install GDAL>=3
#NEEDED! sudo apt install gdal-bin
#NEEDED! pip install ogr2osm

source cfg

poly_file=$COUNTRY.poly
bbox_file=$COUNTRY.bbox

# Input PBF
inpbf=$COUNTRY-latest.osm.pbf

if [ -f "land-polygons-split-4326/land_polygons.shp" ]; then
    echo "Land polygons exist!"
else
    echo "Downloading land polygons..."
    rm -rf "land-polygons-split-4326"
    rm -f "land-polygons-split-4326.zip"
    wget -v -N https://osmdata.openstreetmap.de/download/land-polygons-split-4326.zip || exit 1
    unzip -o "land-polygons-split-4326.zip" -d "./"
    rm -f "land-polygons-split-4326.zip"
fi

# Bounds
BBOX=$(perl poly2bb.pl "${poly_file}")
echo "$BBOX" >${bbox_file}

BBOX=(${BBOX//,/ })
BOTTOM=${BBOX[0]}
LEFT=${BBOX[1]}
TOP=${BBOX[2]}
RIGHT=${BBOX[3]}

# Start position
CENTER=$(perl poly2center.pl "${poly_file}")
CENTER=(${CENTER//,/ })
LAT=${CENTER[0]}
LON=${CENTER[1]}

mkdir -p COAST_TEMP

# Land
ogr2ogr -overwrite -progress -skipfailures -clipsrc $LEFT $BOTTOM $RIGHT $TOP "COAST_TEMP/${COUNTRY}_land.shp" "land-polygons-split-4326/land_polygons.shp"
#ogr2osm  --id 22951459320 --positive-id --add-version --add-timestamp -f -o "COAST_TEMP/${COUNTRY}_land.osm" "COAST_TEMP/${COUNTRY}_land.shp"
python3 shape2osm.py -l "COAST_TEMP/${COUNTRY}_land" "COAST_TEMP/${COUNTRY}_land.shp"
# Sea
#ogr2ogr -overwrite -progress -skipfailures -clipsrc $LEFT $BOTTOM $RIGHT $TOP "COAST_TEMP/${COUNTRY}_sea.shp" "water-polygons-split-4326/water_polygons.shp"
#ogr2osm  --positive-id --add-version --add-timestamp -f -o "COAST_TEMP/${COUNTRY}_sea.osm" "COAST_TEMP/${COUNTRY}_sea.shp"

sea_file="${COUNTRY}_sea.osm"
cp sea.osm "${sea_file}"
sed -i "s/\$BOTTOM/$BOTTOM/g" "${sea_file}"
sed -i "s/\$LEFT/$LEFT/g" "${sea_file}"
sed -i "s/\$TOP/$TOP/g" "${sea_file}"
sed -i "s/\$RIGHT/$RIGHT/g" "${sea_file}"

NEWS_FILE=$COUNTRY-news.osm
NEWS=""

if [ -f "$NEWS_FILE" ]; then
	NEWS="--rx $NEWS_FILE --merge"
fi

UPDATEFILE=${COUNTRY}-latest-update.osm.pbf
if [[ -f "$UPDATEFILE" ]]; then
    PBF_FILE=$UPDATEFILE
fi

#osmosis/bin/osmosis --rb file=$PBF_FILE --rx file=${COUNTRY}_sea.osm --sort --merge --rx file="./COAST_TEMP/${COUNTRY}_land1.osm" --sort --merge --wb file=${COUNTRY}_merge.pbf omitmetadata=true

#args=(--rb file=${COUNTRY}_merge.pbf --rx file="$ROUTES_FILE")
args=(--rb file="$PBF_FILE" --rx file="${COUNTRY}_sea.osm" --sort --merge --rx file="./COAST_TEMP/${COUNTRY}_land1.osm" --sort --merge --rx file="$ROUTES_FILE")
argsnumber=2
for file in *$COUNTRY*view1*view3*.pbf; do
	args+=(--rb "$file")
	argsnumber=$((argsnumber+1))
done
# for file in *$COUNTRY*local-source*; do
# 	args+=(--rb "$file")
# 	argsnumber=$((argsnumber+1))
# done
i=0
while [ $i -lt $((argsnumber-1)) ]; do
	args+=(--sort --merge)
	i=$((i+1))
done
args+=($NEWS)

args+=(--mapfile-writer tag-conf-file=tagmapping-urban.xml type=$MAPSFORGE_TYPE file=$MAP_FILE tag-values=true preferred-languages=hr threads=8 bbox=$BOTTOM,$LEFT,$TOP,$RIGHT map-start-position=$LAT,$LON)

#osmosis/bin/osmosis "${args[@]}"

echo "${args[@]}"
osmosis/bin/osmosis "${args[@]}"