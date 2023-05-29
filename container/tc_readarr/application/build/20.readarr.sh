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

export app_name="readarr"
export app_url="https://www.readarr.com/"
export app_destdir="/opt/Readarr"

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
			local APPARCH="x64" ;;
		aarch64)
			local APPARCH="arm64" ;;
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
		local VERSION=${VERSION:-"0.1.0.1060"}
	fi
	## Readarr is currently only doing nightlies
	#local APPURL="https://readarr.servarr.com/v1/update/develop/updatefile?os=linuxmusl&runtime=netcore&arch=x64"
	local APPURL="https://readarr.servarr.com/v1/update/nightly/updatefile?os=linuxmusl&runtime=netcore&arch=${APPARCH}"

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
