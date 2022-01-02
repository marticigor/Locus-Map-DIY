#!/bin/bash

currentdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source cfg
export SRTM_PATH=$currentdir/srtm
export PLANET_FILE=$currentdir/${COUNTRY}-latest.osm.pbf
cd $currentdir/brouter-master/misc/scripts/mapcreation
./process_pbf_moj.sh