#!/bin/bash

currentdir="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"
source cfg
export SRTM_PATH=$currentdir/srtm
args=()
argsnumber=0
for val in "${StringArray[@]}"; do
    args+=(--rb file=$val-latest.osm.pbf)
    argsnumber=$((argsnumber + 1))
done
i=0
while [ $i -lt $((argsnumber - 1)) ]; do
    args+=(--sort --merge)
    i=$((i + 1))
done
args+=(--wb file=brouter_merge.pbf omitmetadata=true)
echo "${args[@]}"
osmosis/bin/osmosis "${args[@]}"
export PLANET_FILE=$currentdir/brouter_merge.pbf
cd $currentdir/brouter-master/misc/scripts/mapcreation
./process_pbf_moj.sh
