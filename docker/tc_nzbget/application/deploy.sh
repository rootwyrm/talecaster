#!/bin/bash
## transmission/application/deploy.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# 
# COMMERCIAL DISTRIBUTION IN ANY FORM IS EXPRESSLY PROHIBITED WITHOUT
# WRITTEN CONSENT.

export app_name="nzbget"
export app_url="http://www.nzbget.net/"
export app_git_url=""
#export app_destdir=""

export app_cmd="/opt/nzbget/nzbget"
export app_svname="nzbget"
export app_psname="nzbget"

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

	for cdir in scripts queue tmp; do
		test -d /config/$cdir
		if [ $? -ne 0 ]; then
			mkdir /config/$cdir
			chown $tcuid:$tcgid /config/$cdir
		fi
	done
	
	for ddir in intermediate; do
		test -d /downloads/$ddir
		if [ $? -ne 0 ]; then
			mkdir /downloads/$ddir
			chown $tcuid:$tcgid /downloads/$ddir
		fi
	done

	for cfile in nzbget.conf; do
		test -f /config/$cfile
		if [ $? -ne 0 ]; then
			touch /config/$cfile
		else
			cp /config/$cfile /config/"$cfile".bak
			cat /dev/null > /config/$cfile
		fi
	done

	test -d /var/run/$app_name
	if [ $? -ne 0 ]; then
		mkdir /var/run/$app_name
		chown $tcuid:$tcgid /var/run/$app_name
	fi
}

config_copybase()
{
	## Only has one config file
	export basecfg="/config/nzbget.conf"
	if [[ $(test -f $basecfg) -eq 0 ]]; then
		## Back it up.
		echo "[NOTICE] Backing up your existing $basecfg"
		cp $basecfg "$basecfg".bak
	fi

	cp /opt/talecaster/defaults/nzbget.conf $basecfg
	if [ $? -ne 0 ]; then
		RC=$?
		return $rc
	else
		return 0
	fi 
}

######################################################################
## Application Install
######################################################################
application_install()
{
	test -d /opt/nzbget
	if [ $? -eq 0 ]; then
		echo "[FATAL] Found existing nzbget installation!"
		exit 1
	fi

	## Downloading from Github is funky.
	echo "[INSTALL] Retrieving nzbget 18.0 from official"
	curl -L https://github.com/nzbget/nzbget/releases/download/v18.0/nzbget-18.0-bin-linux.run > /opt/talecaster/nzbget-18.0-bin-linux.run
	chmod +x /opt/talecaster/nzbget-18.0-bin-linux.run
	/opt/talecaster/nzbget-18.0-bin-linux.run --destdir /opt/nzbget
	if [ $? -ne 0 ]; then
		echo "[FATAL] Error occurred during nzbget installation!"
		exit 1
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

application_install
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
