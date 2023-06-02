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

## Set up our Dockerfiles first
set -e 
for x in tc_docker tc_bazarr tc_frontend tc_lidarr tc_mylar tc_prowlarr tc_qbittorrent tc_radarr tc_readarr tc_sabnzbd tc_sonarr; do
	cd $work/container/$x
	echo "Creating $x Dockerfile.test"
	cp Dockerfile Dockerfile.test
	echo "Changing TaleCaster FROM entries."
	sed -i -e 's/FROM.*tc_docker.*/FROM tc_docker:latest/' Dockerfile.test
done
set +e

## Having now created our dockerfiles, we need to build them all locally.
## XXX: don't set -e, errors are normal here on a fresh run
echo "Cleaning stale images..."
for img in tc_docker tc_bazarr tc_frontend tc_lidarr tc_mylar tc_prowlarr tc_qbittorrent tc_radarr tc_readarr tc_sabnzbd tc_sonarr; do
	docker rmi $img:latest
	docker system prune -f
done

cd $work
for bld in tc_docker tc_bazarr tc_frontend tc_lidarr tc_mylar tc_prowlarr tc_qbittorrent tc_radarr tc_readarr tc_sabnzbd tc_sonarr; do
	## Bail out in here if a container is failing build
	cd $work/container/$bld
	docker build --progress=plain -t $bld -f Dockerfile.test .
	if [ $? -ne 0 ]; then
		printf '!!! Build of %s failed\n' "$bld"
		exit 1
	fi
done

## XXX: This relies on the fixed compose file in this directory.
cd $start
if [ ! -f suite_compose.yml ]; then
	echo "********************************************************************************"
	echo "!!! suite_compose.yml missing"
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

docker compose -f suite_compose.yml create
if [ $? -ne 0 ]; then
	RC=$?
	printf '!!! Error in compose create - %s\n' "$RC"
	exit $RC
fi

docker compose -f suite_compose.yml start
if [ $? -ne 0 ]; then
	RC=$?
	printf '!!! Error in compose start - %s\n' "$RC"
	exit $RC
fi

echo "********************************************************************************"
echo ">>> Local spinup completed successfully."
echo "********************************************************************************"
