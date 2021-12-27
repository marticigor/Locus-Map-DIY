source cfg

phyghtmap --polygon=$COUNTRY.poly --no-zero-contour --pbf --source=view1,view3 -o $COUNTRY-latest --max-nodes-per-way=200 --start-node-id=10000000000 --start-way-id=10000000000 --max-nodes-per-tile=0
