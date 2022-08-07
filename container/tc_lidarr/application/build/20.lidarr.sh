#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.lidarr.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="Lidarr"
export app_url="http://www.lidarr.audio/"
export app_destdir="/opt/Lidarr"

if [ -f /opt/talecaster/${app_name,,}.version ]; then
	VERSION=$(cat /opt/talecaster/${app_name,,}.version)
else
	export VERSION="0.8.1.2135"
fi
export APPURL="https://github.com/lidarr/Lidarr/releases/download/v${VERSION}/Lidarr.master.${VERSION}.linux-musl-core-x64.tar.gz"

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
	printf '[INSTALL] Retrieving %s version %s...\n' "$app_name" "$VERSION"
	curl -L $APPURL > /tmp/${app_name}.tgz
	tar xf /tmp/${app_name}.tgz -C /opt/
	CHECK_ERROR $? ${app_name}_extract
}

######################################################################
## Execution Phase
######################################################################

echo "Entering $0"
load_config
/opt/talecaster/bin/install_dotnet.sh

LOG "[BUILD] Installing ${app_name}"
application_install
