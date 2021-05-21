#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.nzbget.sh
. /opt/talecaster/lib/talecaster.lib.sh

export app_name="Jackett"
export app_url="https://github.com/Jackett/Jackett"
export app_destdir="/opt/Jackett"

case $(uname -m) in
	x86_64)
		export APPARCH="LinuxAMDx64" ;;
	aarch64)
		export APPARCH="LinuxARM64" ;;
	*)
		echo "Unsupported architecture!"
		exit 255
		;;
esac
export VERSION="0.18.98"
export APPURL="https://github.com/Jackett/Jackett/releases/download/v${VERSION}/Jackett.Binaries.${APPARCH}.tar.gz"

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
/opt/talecaster/bin/install_dotnet.sh

LOG "[BUILD] Installing ${app_name}"
application_install
