#!/bin/bash
THIS_UNIT=tt_qbittorrent
THIS_PORT=9091
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
	#sudo rm -rf /tmp/talecaster/config/*
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
	--name ${THIS_UNIT} \
	-e POSTGRESQL_HOST="10.1.0.57" \
	-e POSTGRESQL_USER="talecaster" \
	-e POSTGRESQL_PASS="Amr90.abigail" \
	${THIS_UNIT}

## Update python stuff
docker cp $HOME/talecaster/container/tc_docker/application/bin/vpn_config.py ${THIS_UNIT}:/opt/talecaster/bin/vpn_config.py
docker cp $HOME/talecaster/container/tc_docker/application/bin/entry.sh ${THIS_UNIT}:/opt/talecaster/bin/entry.sh
docker cp $HOME/talecaster/container/tc_docker/application/bin/configure.py ${THIS_UNIT}:/opt/talecaster/bin/configure.py

docker start ${THIS_UNIT}
