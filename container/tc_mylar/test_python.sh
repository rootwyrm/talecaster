#!/bin/bash

THIS_UNIT=tt_mylar

docker cp $HOME/talecaster/container/tc_docker/application/bin/entry.sh ${THIS_UNIT}:/opt/talecaster/bin/entry.sh
docker cp $HOME/talecaster/container/tc_docker/application/bin/configure.py ${THIS_UNIT}:/opt/talecaster/bin/configure.py

sudo rm -rf /tmp/talecaster/config/*

docker stop $THIS_UNIT
docker start $THIS_UNIT
docker logs -f $THIS_UNIT
