#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.nzbget.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="nzbget"
export app_url="http://www.nzbget.net/"
export app_destdir="/opt/nzbget"

export MAJOR="21"
export MINOR="0"
export NZBGET_URL="https://github.com/nzbget/nzbget/releases/download"

######################################################################
## Application Install
######################################################################
application_install()
{
	test -d /opt/nzbget
	if [ $? -eq 0 ]; then
		LOG "Found existing nzbget installation!" E 1
	fi

	## Downloading from Github is funky.
	LOG "[BUILD] Retrieving nzbget ${MAJOR}.${MINOR} from official"
	curl -L ${NZBGET_URL}/v${MAJOR}.${MINOR}/nzbget-${MAJOR}.${MINOR}-bin-linux.run > /opt/talecaster/nzbget-${MAJOR}.${MINOR}-bin-linux.run
	chmod +x /opt/talecaster/nzbget-${MAJOR}.${MINOR}-bin-linux.run
	/opt/talecaster/nzbget-${MAJOR}.${MINOR}-bin-linux.run --destdir ${app_destdir}
	if [ $? -ne 0 ]; then
		log "Error occurred during nzbget installation!" E
		exit 1
	fi
}

######################################################################
## Install configuration files
######################################################################
config_checkdir()
{
	test -d /talecaster/config
	if [ $? -ne 0 ]; then
		echo "[FATAL] /talecaster/config is missing!"
		exit 1
	fi

	for cdir in scripts queue; do
		test -d /talecaster/config/$cdir
		if [ $? -ne 0 ]; then
			mkdir /talecaster/config/$cdir
			chown $tcuid:$tcgid /talecaster/config/$cdir
		fi
	done
	
	#for ddir in intermediate; do
	#	test -d /talecaster/downloads/$ddir
	#	if [ $? -ne 0 ]; then
	#		mkdir /talecaster/downloads/$ddir
	#		chown $tcuid:$tcgid /talecaster/downloads/$ddir
	#	fi
	#done

	for cfile in nzbget.conf; do
		test -f /talecaster/config/$cfile
		if [ $? -ne 0 ]; then
			if [ -f /opt/talecaster/defaults/$cfile ]; then
				cp /opt/talecaster/defaults/$cfile /talecaster/config/$cfile
			else
				log "Could not find a workable configuration." E
			fi
		else
			cp /talecaster/config/$cfile /talecaster/config/"$cfile".bak
			if [ -f /opt/talecaster/defaults/$cfile ]; then
				cp /opt/talecaster/defaults/$cfile /talecaster/config/$cfile
			else
				log "Could not find a workable configuration." E
			fi
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
## Execution Phase
######################################################################

echo "Entering $0"
load_config

LOG "[BUILD] Installing ${app_name}"
application_install
