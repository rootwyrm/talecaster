#!/bin/bash

## Rebuild the base first, tired of two tabs.
#cd $HOME/talecaster/container/tc_docker 
#$HOME/talecaster/container/tc_docker/test_build.sh
#cd ../tc_prowlarr

THIS_UNIT=tt_mylar
THIS_PORT=8090
TALECASTER_BASE="devel"
docker build --progress=plain --build-arg "TALECASTER_BASE=${TALECASTER_BASE}" . -t ${THIS_UNIT}

if [ ! -d /tmp/talecaster ]; then
	mkdir /tmp/talecaster
fi
for x in blackhole downloads; do
	if [ -d /tmp/talecaster/$x ]; then
		sudo rm -rf /tmp/talecaster/$x/*
	elif [ ! -d /tmp/talecaster/$x ]; then
		mkdir /tmp/talecaster/$x
	fi
	sudo rm -rf /tmp/talecaster/config/*
done


docker kill ${THIS_UNIT}
docker rm ${THIS_UNIT}
docker rmi ${THIS_UNIT}

docker build --progress=plain --build-arg "TALECASTER_BASE=${TALECASTER_BASE}" . -t ${THIS_UNIT}

docker create \
	-p ${THIS_PORT}:${THIS_PORT}\
	-v /tmp/talecaster/blackhole:/talecaster/blackhole \
	-v /tmp/talecaster/config:/talecaster/config \
	-v /tmp/talecaster/downloads:/talecaster/downloads \
	-v /tmp/talecaster/shared:/talecaster/shared \
	--cap-add=NET_ADMIN \
	--device /dev/net/tun \
	--name ${THIS_UNIT} \
	${THIS_UNIT}
	#-e INDEXER_VPN_CONFIG="/talecaster/shared/vpn.conf" \
	#-e INDEXER_VPN="false" \

docker start ${THIS_UNIT}
docker stop ${THIS_UNIT}
docker cp $HOME/talecaster/container/tc_docker/application/bin/entry.sh ${THIS_UNIT}:/opt/talecaster/bin/entry.sh
docker cp $HOME/talecaster/container/tc_docker/application/bin/configure.py ${THIS_UNIT}:/opt/talecaster/bin/configure.py

docker start ${THIS_UNIT}
