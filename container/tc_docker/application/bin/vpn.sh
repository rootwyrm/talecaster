#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/bin/vpn.sh

. /opt/talecaster/lib/talecaster.lib.sh

## Check if we're in a sane state.
function sanity_check()
{
	local svc=$(cat /opt/talecaster/id.provides)
	if [ -z ${svc^^}_VPN ]; then
		## We are definitely not.
		exit 2
	elif [ ${svc^^}_VPN == 'true' ]; then
		## We're at least partly sane.
		if [ -z ${svc^^}_VPN_CONFIG ] || [ ${svc^^}_VPN_CONFIG == "" ]; then
			## Nope, not sane.
			exit 2
		elif [ -z ${svc^^}_VPN_USER ] || [ ${svc^^}_VPN_USER == "" ]; then
			## XXX: This actually might occur with cert authentication
			## Nope, not sane.
			exit 2
		elif [ -z ${svc^^}_VPN_PASS ] || [ ${svc^^}_VPN_PASS == "" ]; then
			## XXX: This actually might occur with cert authentication
			## Nope, not sane.
			exit 2
		else
			export SVC=${svc^^}
			export VPN_ENABLE=1
		fi
	fi
}

## test_config ${SVC}_VPN_CONFIG
function test_config()
{
	if [ ! -f $1 ] || [ -z $1 ]; then
		## Hit test_config without a config file
		exit 2
	fi
	## Ensure we have a valid device
	if [[ $(grep ^dev $1 | awk '{print $2}') != 'tun' ]]; then
		printf 'Configuration file invalid - only tun devices supported!\n'
		exit 10
	fi
	## This can be done in Perl, but don't want the Perl dep. Oh well. 
	if [ $(grep proto > /dev/null; echo $?) -ne 0 ]; then
		printf 'Configuration file invalid - no protocol defined!\n'
		exit 10
	fi
	if [ $(grep cipher > /dev/null; echo $?) -ne 0 ]; then
		printf 'Configuration file invalid - no cipher defined!\n'
		exit 10
	fi
}

## update_rc ${SVC}_VPN_CONFIG
function update_rc()
{
	ln -sf /etc/init.d/openvpn /etc/init.d/openvpn.talecaster
	local confd=/etc/conf.d/openvpn.talecaster
	echo 'detect_client="yes"' > $confd
	echo "cfgfile=/talecaster/config/${SVC}_VPN_CONFIG" >> $confd
	## XXX: Prevent peer DNS because it's usually broken, 
	##      we have a workaround.
	echo 'peer_dns="no"' >> $confd
	## NYI: need our own vpn up and down scripts.
	/sbin/rc-update enable openvpn.talecaster
}

## vpn_gateway
## Records and checks gateway status.
function vpn_gateway()
{
	local my_gw=$(netstat -rn | grep ^0.0.0.0 | grep tun0$ | awk '{print $2}')
	if [ -z $my_gw ] || [ $my_gw == "" ]; then
		printf 'Could not determine gateway!\n'
		exit 2
	fi
	ping -c 4 $my_gw > /dev/null
	if [ $? -ne 0 ]; then
		printf 'VPN gateway did not respond to ping.\n'
		exit 2
	fi
	## Stash it in a temp file.
	echo $my_gw > /tmp/talecaster.vpn.gw
}

## fix_resolv
## Work around a known Docker issue with DNS, because it insists on being 
## a DNS server. And implements it incorrectly. Which is just... <facepalm>
function fix_resolv()
{
	if [ -f /etc/resolv.conf ]; then
		mv /etc/resolv.conf /etc/resolv.conf.bak
	fi
	local mysearch=$(grep ^search /etc/resolv.conf)
	if [ ! -z $mysearch ] || [ $mysearch != "" ]; then
		echo 'search $mysearch' > /etc/resolv.conf
	fi
	for ns in 9.9.9.9 149.112.112.112; do
		echo "nameserver $ns" >> /etc/resolv.conf
	done
	## Set options correctly
	echo "options rotate" >> /etc/resolv.conf
}

