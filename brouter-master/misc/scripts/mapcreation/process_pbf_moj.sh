#!/bin/sh
set -e

# Added
JAVA='java -Xmx3072m -Xms3072m -Xmn256m'
BROUTER_PROFILES=$(realpath "../../profiles2")
BROUTER_JAR=$(realpath $(ls ../../../brouter-server/build/libs/brouter-*-all.jar))
OSMOSIS_JAR=$(realpath "../../pbfparser/osmosis.jar")
PROTOBUF_JAR=$(realpath "../../pbfparser/protobuf.jar")
PBFPARSER_JAR=$(realpath "../../pbfparser/pbfparser.jar")
#PLANET_FILE=${PLANET_FILE:-$(realpath "./planet-latest.osm.pbf")} # (!) expects PLANET_FILE to be set OR 'planet-latest.osm.pbf'
#SRTM_PATH=/home/user/workspace/brouter_original/misc/scripts/mapcreation/srtm

#rm -rf planet-old.osm.pbf
#rm -rf planet-new.osm.pbf
touch mapsnapshpttime.txt

rm -rf tmp

mkdir tmp
cd tmp
mkdir nodetiles
mkdir waytiles
mkdir waytiles55
mkdir nodes55

$JAVA -cp ${OSMOSIS_JAR}:${PROTOBUF_JAR}:${PBFPARSER_JAR}:${BROUTER_JAR} \
	-Ddeletetmpfiles=true -DuseDenseMaps=true \
	btools.util.StackSampler btools.mapcreator.OsmFastCutter \
	${BROUTER_PROFILES}/lookups.dat nodetiles waytiles nodes55 waytiles55 \
	bordernids.dat  relations.dat  restrictions.dat \
	${BROUTER_PROFILES}/all.brf ${BROUTER_PROFILES}/trekking.brf ${BROUTER_PROFILES}/softaccess.brf \
	${PLANET_FILE}

printf "\n\n---------------------- unotes55 -----------------\n\n\n"
mkdir unodes55
$JAVA -cp ${BROUTER_JAR} -Ddeletetmpfiles=true -DuseDenseMaps=true btools.util.StackSampler \
	btools.mapcreator.PosUnifier nodes55 unodes55 bordernids.dat bordernodes.dat ${SRTM_PATH}

printf "\n\n---------------------- segments -----------------\n\n\n"
mkdir segments
$JAVA -cp ${BROUTER_JAR} -DuseDenseMaps=true -DskipEncodingCheck=true btools.util.StackSampler \
	btools.mapcreator.WayLinker unodes55 waytiles55 bordernodes.dat restrictions.dat ${BROUTER_PROFILES}/lookups.dat \
	${BROUTER_PROFILES}/all.brf segments rd5

cd ..

rm -rf segments
mv tmp/segments segments
touch -r mapsnapshpttime.txt segments/*.rd5