#!/bin/bash
## transmission/application/deploy.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# 
# COMMERCIAL DISTRIBUTION IN ANY FORM IS EXPRESSLY PROHIBITED WITHOUT
# WRITTEN CONSENT.

export app_name="transmission"
export app_url="http://www.transmissionbt.com/"
export app_git_url=""
#export app_destdir=""

export app_cmd="/usr/bin/transmission-daemon"
export app_svname="transmission"
export app_psname="transmission-daemon"

## Ingest library
. /opt/talecaster/lib/deploy.lib.sh

######################################################################
## Install configuration files
######################################################################
config_checkdir()
{
	test -d /config
	if [ $? -ne 0 ]; then
		echo "[FATAL] /config is missing!"
		exit 1
	fi

	for cdir in blocklists resume torrents; do
		test -d /config/$cdir
		if [ $? -ne 0 ]; then
			mkdir /config/$cdir
			chown $tcuser:$tcgroup /config/$ddir
		fi
	done
	
	for ddir in blackhole incomplete; do
		test -d /downloads/$ddir
		if [ $? -ne 0 ]; then
			mkdir /downloads/$ddir
			chown $tcuid:$tcgid /downloads/$ddir
		fi
	done

	for cfile in stats.json; do
		test -f /config/$cfile
		if [ $? -ne 0 ]; then
			touch /config/$cfile
		else
			cp /config/$cfile /config/"$cfile".bak
			cat /dev/null > /config/$cfile
		fi
	done

	## Configure logging correctly
	chown $tcuid:$tcgid /var/log/transmission

	test -d /var/run/$app_name
	if [ $? -ne 0 ]; then
		mkdir /var/run/$app_name
		chown $tcuid:$tcgid /var/run/$app_name
	fi
}

config_copybase()
{
	## Only has one config file
	export basecfg="/config/settings.json"
	if [ -f $basecfg ]; then
		## Back it up.
		echo "[NOTICE] Backing up your existing /config/settings.json"
		cp /config/$basecfg /config/"$basecfg".bak
	fi

	cp /opt/talecaster/defaults/settings.json $basecfg
	if [ $? -ne 0 ]; then
		RC=$?
		return $rc
	else
		return 0
	fi 
}

######################################################################
## Execution Phase
######################################################################

ingest_environment
test_deploy

generate_motd
cat /etc/motd

echo "[DEPLOY] Deploying TaleCaster user"
deploy_talecaster_user

config_checkdir
config_copybase

echo "[DEPLOY] Adjusting file ownership"
deploy_tcuser_ownership

runit_linksv

deploy_complete

echo "[DEPLOY] Initial deployment complete."
if [ -f /firstboot ]; then
	rm /firstboot
fi

## Print a double newline for cleanliness
echo " "
echo " " 
