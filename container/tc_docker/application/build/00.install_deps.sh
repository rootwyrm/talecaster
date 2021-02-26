#!/usr/bin/env bash
################################################################################
# TaleCaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com> and its
# contributors.
# All rights reserved
# 
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## application/build/00.install_deps.sh

. /opt/talecaster/lib/talecaster.lib.sh

SERVICE=$(cat /opt/talecaster/id.service)

function install_deps()
{
	if [ -f /opt/talecaster/${SERVICE}.deps ]; then
		apk --no-cache add $(cat /opt/talecaster/${SERVICE}.deps)
		CHECK_ERROR $? install_deps

	elif [ -z $SERVICE ] || [ ! -f /opt/talecaster/id.service ]; then
		LOG "No service assigned."
	else
		LOG "No dependencies for ${SERVICE}"
	fi

	case ${SERVICE}_VPN in
		[Tt][Rr][Uu][Ee])
			if [ ! -c /dev/net/tun ]; then
				printf 'VPN requested but tunnel device not available!\n'
				exit 255
			fi
			apk --no-cache add openvpn openvpn-openrc
			rc-update add openvpn
			;;
		wireguard)
			## XXX: NOT READY FOR USE!!
			if [ ! -c /dev/net/tun ]; then
				printf 'VPN requested but tunnel device not available!\n'
				exit 255
			fi
			apk --no-cache add wireguard-tools ifupdown-ng-wireguard
			## XXX: seriously, doesn't do anything but add package for now.
		*)
			## Do nothing
			;;
	esac
}

install_deps
