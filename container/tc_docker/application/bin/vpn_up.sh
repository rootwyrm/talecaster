#!/bin/sh
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/bin/vpn_up.sh

## XXX: This has to be re-run every time the VPN comes up.
## Set resolvers, default to Quad9
TC_RESOLV0="${TC_RESOLV0:-9.9.9.9}"
TC_RESOLV1="${TC_RESOLV1:-149.112.112.112}"

## XXX: We ignore a bunch of dhcp options deliberately here. Too often they're
##      broken by the provider, or the provider's DNS doesn't work, etc.
##		We also have to actively block some that Docker sets, or DNS stops
##      working for VPN'd containers because of enforced bad routing. >:|
if [ -f /etc/resolv.conf ]; then
	mv /etc/resolv.conf /etc/resolv.conf.bak
fi
if [ -z $TC_DOMAIN ]; then
	grep ^search /etc/resolv.conf.bak > /dev/null
	if [ $? -eq 0 ]; then
		grep ^search /etc/resolv.conf.bak > /opt/talecaster/resolv.conf
	else
		echo "search ${TC_DOMAIN}" > /opt/talecaster/resolv.conf
	fi
fi
echo "nameserver ${TC_RESOLV0}" >> /opt/talecaster/resolv.conf
echo "nameserver ${TC_RESOLV1}" >> /opt/talecaster/resolv.conf
## Options are always set this way. Always.
echo "options ndots:0" >> /opt/talecaster/resolv.conf

ln -sf /opt/talecaster/resolv.conf /etc/resolv.conf

## Restart our service so that it picks up interfaces correctly.
SERVICE=$(cat /opt/talecaster/id.service)
service stop $SERVICE && sleep 5 && service start $SERVICE
