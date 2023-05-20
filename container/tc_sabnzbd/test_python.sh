#!/bin/bash

THIS_UNIT=tt_sabnzbd

docker cp $HOME/talecaster/container/tc_docker/application/bin/entry.sh ${THIS_UNIT}:/opt/talecaster/bin/entry.sh
docker cp $HOME/talecaster/container/tc_docker/application/bin/configure.py ${THIS_UNIT}:/opt/talecaster/bin/configure.py
docker cp $HOME/talecaster/container/tc_sabnzbd/etc/sabnzbd.base.ini ${THIS_UNIT}:/etc/sabnzbd.base.ini
docker cp $HOME/talecaster/container/tc_sabnzbd/etc/sabnzbd.categories.ini ${THIS_UNIT}:/etc/sabnzbd.categories.ini

docker stop $THIS_UNIT
docker start $THIS_UNIT
docker logs -f $THIS_UNIT
