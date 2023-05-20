#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="sabnzbd"
export app_url="http://www.sabnzbd.org/"
export app_destdir="/opt/sabnzbd"

# architecture irrelevant

if [ -f /opt/talecaster/${app_name,,}.version ]; then
	export VERSION=$(cat /opt/talecaster/${app_name,,}.version)
else
	export VERSION="4.0.1"
fi
#https://github.com/sabnzbd/sabnzbd/releases/download/4.0.1/SABnzbd-4.0.1-src.tar.gz
export APPURL="https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz"

######################################################################
## Application Install
######################################################################
application_install()
{
	test -d $app_destdir
	if [ $? -eq 0 ]; then
		LOG "Found existing installation!" E 1
	fi
	mkdir $app_destdir

	#LOG "[BUILD] Initializing virtual environment for SABnzbd"
	#python3.10 -m venv $app_destdir	
	#LOG "[BUILD] Activating virtual environment"
	#. $app_destdir/bin/activate
	LOG "[BUILD] Retrieving SABnzbd ${VERSION} from Github"
	curl -L ${APPURL} -o /tmp/SABnzbd.tgz
	if [ $? -ne 0 ]; then
		log "Error occurred during SABnzbd retrieval!" E 10
		exit 10
	fi
	tar xf /tmp/SABnzbd.tgz --strip-components=1 -C $app_destdir
	if [ $? -ne 0 ]; then
		LOG "Error occurred extracting SABnzbd release" E 10
		exit 10
	fi
	LOG "[BUILD] Installing SABnzbd requirements.txt"
	. /opt/talecaster/venv/bin/activate
	/opt/talecaster/venv/bin/pip install --upgrade pip
	/opt/talecaster/venv/bin/pip install -r $app_destdir/requirements.txt
	if [ $? -ne 0 ]; then
		LOG "Error occurred installing SABnzbd requirements" E 10
		exit 10
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
