#!/bin/bash
# Perform a local build of all images.

start=$PWD
work=$(dirname $start)

echo $start
echo $work

echo "********************************************************************************"
echo "WARNING: FOR LOCAL TEST BUILDING ONLY. RESULTING BUILDS ARE NON-REPRODUCIBLE"
echo "AND INCOMPLETE. ONLY FOR TESTING STACK BUILD AND STARTUP."
echo "********************************************************************************"

## Having now created our dockerfiles, we need to build them all locally.
## XXX: don't set -e, errors are normal here on a fresh run
echo "Cleaning stale images..."
cd $start
docker compose -f suite_compose.yml stop 
docker compose -f suite_compose.yml rm -y
docker compose -f devel_compose.yml stop
docker compose -f devel_compose.yml rm -y
for img in tc_docker tc_bazarr tc_frontend tc_lidarr tc_mylar tc_prowlarr tc_qbittorrent tc_radarr tc_readarr tc_sabnzbd tc_sonarr; do
	docker rmi $img:latest
	docker system prune -f
done

## XXX: This relies on the fixed compose file in this directory.
cd $start
if [ ! -f devel_compose.yml ]; then
	echo "********************************************************************************"
	echo "!!! devel_compose.yml missing"
	exit 1
fi
## Create our directories.
printf '>>> Cleaning up previous run... '
for x in blackhole downloads shared config books comics movies music television; do
	if [ -d /tmp/tc/$x ]; then
		printf '%s' "$x"
		sudo rm -rf /tmp/tc/$x
		if [ $? -ne 0 ]; then
			printf '\n!!! Error removing /tmp/tc/%s\n' "$x"
			exit 1
		fi
	fi
done
printf '\n'

printf '>>> Creating temporary volumes for run... '
if [ ! -d /tmp/tc ]; then
	mkdir /tmp/tc
fi
for x in blackhole downloads shared config books comics movies music television; do
	printf '%s' "$x"
	mkdir /tmp/tc/$x
	if [ $? -ne 0 ]; then
		printf '\n!!! Error creating /tmp/tc/%s\n' "$x"
		exit 1
	fi
done
printf '\n'

docker compose -f devel_compose.yml pull
docker compose -f devel_compose.yml create
if [ $? -ne 0 ]; then
	RC=$?
	printf '!!! Error in compose create - %s\n' "$RC"
	exit $RC
fi

docker compose -f devel_compose.yml start
if [ $? -ne 0 ]; then
	RC=$?
	printf '!!! Error in compose start - %s\n' "$RC"
	exit $RC
fi

echo "********************************************************************************"
echo ">>> Local spinup completed successfully."
echo "********************************************************************************"
