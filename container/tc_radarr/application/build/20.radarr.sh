#!/usr/bin/env bash
###############################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.radarr.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="Radarr"
export app_url="http://www.radarr.video/"
export app_destdir="/opt/Radarr"

######################################################################
## Application Install
######################################################################
application_install()
{
	test -d ${app_destdir}
	if [ $? -eq 0 ]; then
		log "Found existing ${app_name} installation!" E
		exit 1
	fi

	## Downloading from Github is funky.
	echo "[INSTALL] Retrieving ${app_name}..."
	curl -L $APPURL > /tmp/${app_name}.tgz
	tar xf /tmp/${app_name}.tgz -C /opt/
	CHECK_ERROR $? ${app_name}_extract
}

######################################################################
## Execution Phase
######################################################################

echo "Entering $0"
load_config

if [ ! -f /usr/local/bin/mono ]; then
	/opt/talecaster/bin/install_dotnet.sh
	## Install the dotnet initscript
	ln -sf /etc/init.d/radarr-dotnet /etc/init.d/radarr
	## Set URL for .NET app
	export APPURL="https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64"
else
	ln -sf /etc/init.d/radarr-mono /etc/init.d/radarr
	export APPURL="https://radarr.servarr.com/v1/update/master/updatefile?os=linux"
fi
LOG "[BUILD] Installing ${app_name}"
application_install
