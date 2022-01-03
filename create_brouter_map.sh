#!/bin/bash

currentdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source cfg
export SRTM_PATH=$currentdir/srtm
osmosis/bin/osmosis --rb file=croatia-latest.osm.pbf --rb file=slovenia-latest.osm.pbf --sort --merge --wb file=brouter_merge.pbf omitmetadata=true
export PLANET_FILE=$currentdir/brouter_merge.pbf
cd $currentdir/brouter-master/misc/scripts/mapcreation
./process_pbf_moj.sh