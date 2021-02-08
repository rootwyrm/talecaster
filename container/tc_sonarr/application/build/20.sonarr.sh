#!/bin/bash
###############################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.nzbget.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="Sonarr"
export app_url="http://www.sonarr.tv/"
export app_destdir="/opt/Sonarr"

export BRANCH="phantom-develop"
export VERSION="3"
export APPURL="https://services.sonarr.tv/v1/download/phantom-develop/latest?version=3&os=linux"

######################################################################
## Application Install
######################################################################
application_install()
{
	test -d /opt/Sonarr
	if [ $? -eq 0 ]; then
		log "Found existing ${app_name} installation!" E
		exit 1
	fi

	## Downloading from Github is funky.
	echo "[INSTALL] Retrieving ${app_name}..."
	curl -L $APPURL > /tmp/Sonarr.tgz
	tar xf /tmp/Sonarr.tgz -C /opt/
	CHECK_ERROR $? sonarr_extract
}

######################################################################
## Execution Phase
######################################################################

echo "Entering $0"
load_config

LOG "[BUILD] Installing ${app_name}"
application_install
