#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## application/build/20.transmission.sh

. /opt/talecaster/lib/talecaster.lib.sh

function noop()
{
	## Build our configuration...
	LOCALIP=$(hostname -i)
	CONFDIR=/talecaster/config
	SETTINGS=/talecaster/config/settings.json
	transmission_password=${transmission_password:"t4l3caster"}
}

noop
