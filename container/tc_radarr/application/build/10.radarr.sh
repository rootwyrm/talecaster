#!/bin/bash
## application/build/00.radarr.sh
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

test -d /opt/talecaster/build
if [ $? -ne 0 ]; then
	mkdir -p /opt/talecaster/build
fi
bldroot="/opt/talecaster/build"

check_dotnet()
{
	if [ -f /usr/local/bin/dotnet ]; then
		/usr/local/bin/dotnet --info
		if [ $? -eq 0 ]; then
			export DOTNET=1
		else
			export MONO=1
		fi
	else
		"No working .NET interpreter!"
		exit 255
	fi
}

radarr_install()
{
	if [ ${DOTNET} == '1' ]; then
		## Use the dotnet stuff.
		wget --content-disposition 'http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64' -O /root/Radarr.netcore.tar.gz
		tar xf /root/Radarr.netcore.tar.gz -C /opt/talecaster/
		rm /root/Radarr.netcore.tar.gz
		if [ -f /etc/init.d/radarr-netcore ]; then
			/sbin/rc-update add radarr-netcore
		fi
	elif [ ${MONO} == '1' ]; then
		## Use the mono stuff
		wget --content-disposition 'https://radarr.servarr.com/v1/update/master/updatefile?os=linux' -O /root/Radarr.mono.tar.gz
		tar xf /root/Radarr.mono.tar.gz -C /opt/talecaster/
		rm /root/Radarr.mono.tar.gz
		if [ -f /etc/init.d/radarr-mono ]; then
			/sbin/rc-update add radarr-mono
		fi
	fi
}

check_dotnet
radarr_install
