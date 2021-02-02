#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## application/build/00.install_deps.sh

. /opt/talecaster/lib/deploy.lib.sh

SERVICE=$(cat /opt/talecaster/id.service)

function install_deps()
{
	if [ -f /opt/talecaster/${SERVICE}.deps ]; then
		apk --no-cache add $(cat /opt/talecaster/${SERVICE}.deps)
	elif [ -z $SERVICE ] || [ ! -f /opt/talecaster/id.service ]; then
		log "No service assigned."
	else
		log "No dependencies for ${SERVICE}"
	fi
}

install_deps
