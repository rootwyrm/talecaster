#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# periodic/15min/vpn_keepalive.sh

function heartbeat()
{
	if [ -f /opt/talecaster/resolv.conf ]; then
		## Keep Docker from screwing this up, because it will.
		ln -sf /opt/talecaster/resolv.conf /etc/resolv.conf
	fi
	vpngw=$(netstat -rn | grep tun0$ | grep ^0.0.0.0 | awk '{print $2}')
	ping -c 5 $vpngw > /dev/null 2>&1
	if [ $? -ne 0 ] && [ -z $VPN_GW_NOPING ]; then
		## Gateway is nonresponsive to pings
		service openvpn.talecaster restart
	fi

	## Hit some common URLs to keep idle VPN connections alive.
	curl -q https://www.google.com > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		service openvpn.talecaster restart
	fi
	curl -q https://www.bing.com > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		service openvpn.talecaster restart
	fi
}

provide=$(cat /opt/talecaster/id.provides)
if [ -z ${provide^^}_VPN_CONFIG ]; then
	exit 0
else
	heartbeat
fi
