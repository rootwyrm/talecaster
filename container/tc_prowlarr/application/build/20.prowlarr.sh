#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
. /opt/talecaster/lib/talecaster.lib.sh
#set -e

export app_name="prowlarr"
export app_url="https://www.prowlarr.com/"
export app_destdir="/opt/Prowlarr"

#https://services.sonarr.tv/v1/download/develop/latest?version=4&os=linux-musl&arch=arm64
export OSARCH="linux-musl"
export ARCH=$(uname -m)
case $ARCH in
	x86*)
		export ARCH="x64"
		;;
	aarch64*)
		export ARCH="arm64"
		;;
	*)
		echo "Unsupported architecture!"
		exit 255
		;;
esac

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

	## Determine our version
	if [ -f /opt/talecaster/${app_name}.version ]; then
		local VERSION=$(cat /opt/talecaster/${app_name}.version)
	else
		local VERSION=${VERSION:-"1.4.1.3258"}
	fi
	#local APPURL="https://github.com/Prowlarr/Prowlarr/releases/download/v${VERSION}/Prowlarr.master.${VERSION}.linux-musl-core-${ARCH}.tar.gz"
	local APPURL="https://github.com/Prowlarr/Prowlarr/releases/download/v${VERSION}/Prowlarr.master.${VERSION}.linux-musl-core-${ARCH}.tar.gz"
#	echo "$APPURL"
#https://github.com/Prowlarr/Prowlarr/releases/download/v1.4.1.3258/Prowlarr.master.1.4.1.3258.linux-musl-core-.tar.gz


	## Downloading from Github is funky.
	echo "[INSTALL] Retrieving ${app_name} release ${VERSION} ..."
	curl -L $APPURL > /tmp/${app_name}.tgz
	tar xf /tmp/${app_name}.tgz -C /opt/
	CHECK_ERROR $? ${app_name}_extract
}

######################################################################
## Execution Phase
######################################################################

echo "Entering $0"
load_config

LOG "[BUILD] Installing ${app_name}"
application_install
if [ $? -eq 0 ]; then
	# XXX: prowlarr_sync is part of firstboot and crontab
	echo "prowlarr_sync not fixed yet"
	#rc-update add prowlarr_sync
fi
