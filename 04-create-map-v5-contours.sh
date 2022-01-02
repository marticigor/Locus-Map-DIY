#!/bin/bash
source cfg
NEWS_FILE=$COUNTRY-news.osm
NEWS=""

if [ -f "$NEWS_FILE" ]; then
	NEWS="--rx $NEWS_FILE --merge"
fi

UPDATEFILE=${COUNTRY}-latest-update.osm.pbf
if [[ -f "$UPDATEFILE" ]]; then
    PBF_FILE=$UPDATEFILE
fi

#args=(--rb file=$PBF_FILE --rx file="$ROUTES_FILE" --merge)
args=(--rb file=$PBF_FILE --rx file="$ROUTES_FILE" --rx file="./COAST_TEMP/${COUNTRY}_land.osm" --rx file="./COAST_TEMP/${COUNTRY}_sea.osm")
argsnumber=4
for file in *$COUNTRY*view*; do
	args+=(--rb "$file")
	argsnumber=$((argsnumber+1))
done
i=0
while [ $i -lt $((argsnumber-1)) ]; do
	args+=(--merge)
	i=$((i+1))
done
args+=($NEWS)
args+=(--mapfile-writer tag-conf-file=tagmapping-urban.xml type=$MAPSFORGE_TYPE file=$MAP_FILE tag-values=true preferred-languages=hr threads=8)

#osmosis/bin/osmosis "${args[@]}"

echo "${args[@]}"
osmosis/bin/osmosis "${args[@]}"
