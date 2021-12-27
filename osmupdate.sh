source cfg

basemap=$COUNTRY-latest.osm.pbf
updatemap=$COUNTRY-latest-update.osm.pbf
if [[ -f "$updatemap" ]]; then
    cp -fr $updatemap $basemap
    #basemap=$updatemap
fi
osmupdate --hour --day $basemap $updatemap -v

rm -f $basemap
cp -fr $updatemap $basemap

