#!/usr/bin/env bash
###############################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

printf 'Performing quickstart - this will create necessary directories for you\n'
printf 'in the default locations and with the default layout.\n'

if [ ! -d /opt ]; then
	mkdir /opt
	chmod 0755 /opt
	chown root:root /opt
fi
if [ ! -d /opt/talecaster ]; then
	mkdir /opt/talecaster
fi
for x in downloads blackhole television movies music; do
	if [ ! -d /opt/talecaster/$x ]; then
		mkdir /opt/talecaster/$x
	fi
done
if [ ! -d /opt/talecaster/config ]; then
	mkdir /opt/talecaster/config
fi
for x in nntp torrent television movies music; do
	if [ ! -d /opt/talecaster/config/$x ]; then
		mkdir /opt/talecaster/config/$x
	fi
done

## Bring in the default docker.env file
printf 'Downloading default docker.env file...\n'
wget -O /opt/talecaster/docker.env https://github.com/rootwyrm/talecaster/blob/latest/container/docker.env 
printf 'Opening docker.env in your editor.\n'
sleep 5
$EDITOR /opt/talecaster/docker.env
printf 'Reviewing /opt/talecaster/docker.env\n'
cat /opt/talecaster/docker.env
printf '\nIf this looks okay, wait 30 seconds. If you need to make changes, press Ctrl+C and rerun this script.\n'
sleep 30

printf 'Accepted docker.env, composing containers...\n'
. /opt/talecaster/docker.env
## XXX: needs to select the VPN mode
wget -O /opt/talecaster/docker-compose.yml https://github.com/rootwyrm/talecaster/blob/latest/container/docker-compose.yml
docker-compose -f /opt/talecaster/docker-compose.yml up --force-recreate --no-start
if [ $? -ne 0 ]; then
	printf 'An error occurred during compose, aborting!\n'
	exit 1
else
	docker-compose -f /opt/talecaster/docker-compose.yml start -d
	if [ $? -ne 0 ]; then
		printf 'An error occurred starting containers, aborting!\n'
		exit 1
	fi
fi

printf 'TaleCaster initial setup is complete.\n'
