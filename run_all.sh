#!/bin/bash
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

./02*.sh #download latest map (day before at around 21:00)
#create brouter map on original downloaded osm.pbf doesen't work on updated??~??
./create_brouter_map.sh
#currentdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
#mkdir -p $currentdir/segments4
#cp -rf $currentdir/brouter-master/misc/scripts/mapcreation/segments $currentdir/segments4
./copy*brouter*.sh
./osmupdate.sh #update downloaded with latest changes
./03*.sh #extract hiking/cycling routes
./05-create*.sh #create poi db
./coastline-fix-moj.sh

# ./create_brouter_map.sh
# currentdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# mkdir $currentdir/segments4
# cp -rf $currentdir/brouter-master/misc/scripts/mapcreation/segments $currentdir/segments4
