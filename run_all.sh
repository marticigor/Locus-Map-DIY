#!/bin/bash
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

source cfg

create_map() {
  ./copy*brouter*.sh
  ./osmupdate.sh  #update downloaded with latest changes
  ./03*.sh        #extract hiking/cycling routes
  ./05-create*.sh #create poi db
  ./coastline-fix-moj.sh
}

# Loop through countries, call the scripts in "create_map" function
for val in "${StringArray[@]}"; do
  echo $val
  export COUNTRY=$val
  #./02*.sh #download latest map (day before at around 21:00)
  ./02*.sh
done
#create brouter map on original downloaded osm.pbf doesen't work on updated??~??
./create_brouter_map.sh
for val in "${StringArray[@]}"; do
  export COUNTRY=$val
  create_map
done
