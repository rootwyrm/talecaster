#!/bin/bash

start=$PWD
work=$(dirname $start)

echo "********************************************************************************"
echo ">>> Updating application elements..."
echo "********************************************************************************"

for cnt in music books indexer comics television nntp frontend torrent movies; do
	for p in entry.sh configure.py; do
		docker cp $work/container/tc_docker/application/bin/$p $cnt:/opt/talecaster/bin/$p
	done
done
for cnt in music books indexer comics television nntp frontend torrent movies; do
	docker restart $cnt
done

echo "********************************************************************************"
echo ">>> Application elements updated"
echo "********************************************************************************"


