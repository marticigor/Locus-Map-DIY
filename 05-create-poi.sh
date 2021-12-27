#!/bin/bash
source cfg
UPDATEFILE=${COUNTRY}-latest-update.osm.pbf
if [[ -f "$UPDATEFILE" ]]; then
    PBF_FILE=$UPDATEFILE
fi
python3 poi_converter/poiconverter.py -if pbf -om create $PBF_FILE $POI_FILE

