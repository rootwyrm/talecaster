#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.radarr.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="radarr"
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

	## Determine machine architecture
	case $(uname -m) in
		x86_64)
			local APPARCH="linux-musl-core-x64" ;;
		aarch64)
			local APPARCH="linux-musl-core-arm64" ;;
		*)
			echo "Unsupported architecture!"
			exit 255
			;;
	esac
	if [[ $MONO == 'true' ]]; then
		local APPARCH="linux"
	fi
	## Determine our version
	if [ -f /opt/talecaster/${app_name}.version ]; then
		local VERSION=$(cat /opt/talecaster/${app_name}.version)
	else
		local VERSION=${VERSION:-"3.2.2.5080"}
	fi
	local APPURL="https://github.com/Radarr/Radarr/releases/download/v${VERSION}/Radarr.develop.${VERSION}.${APPARCH}.tar.gz"

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
