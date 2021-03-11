#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/bin/update_dotnet.sh

. /opt/talecaster/lib/talecaster.lib.sh

function existing_version()
{
	export CUR_VERSION=$(dotnet --info | grep Version | cut -d : -f 2)
	export CUR_COMMIT=$(dotnet --info | grep Commit | cut -d : -f 2)
	if [ -f /opt/talecaster/etc/dotnet.sha512 ]; then
		CUR_SHA512=$(cat /opt/talecaster/etc/dotnet.sha512)
	fi
}

## Cope with long-running containers
function check_update()
{
	## dotnet version _always_ tracks latest.
	URL_VERSION=https://github.com/rootwyrm/talecaster/blob/master/container/tc_docker/application/etc/dotnet.release
	URL_SHA512=https://github.com/rootwyrm/talecaster/blob/master/container/tc_docker/application/etc/dotnet.sha512
	URL_PR=https://github.com/rootwyrm/talecaster/blob/master/container/tc_docker/application/etc/dotnet.pr
	URL_KEY=https://github.com/rootwyrm/talecaster/blob/master/container/tc_docker/application/etc/dotnet.key

	wget -O /tmp/dotnet.verison $URL_VERSION
	CHECK_ERROR $? retrieve_latest_version 
	wget -O /tmp/dotnet.sha512 $URL_VERSION
	CHECK_ERROR $? retrieve_latest_sha512
	if [ $(cat /tmp/dotnet.version) != $CUR_VERSION ]; then
		upgrade
	elif [ $(cat /tmp/dotnet.sha512) != $CUR_SHA512 ]; then
		upgrade
	else
		exit 0
	fi
}

## the actual upgrade
function upgrade()
{
	URL_BASE=https://github.com/rootwyrm/talecaster/blob/master/container/tc_docker/application/etc/dotnet
	## We need to do an upgrade.
	log 'Upgrading dotnet from %s to %s\n' "$CUR_VERSION" "$(cat /tmp/dotnet.version)"
	for c in version sha512 pr key; do
		wget -O /opt/talecaster/etc/dotnet.${c} ${URL_BASE}.${c}
		CHECK_ERROR $? update_${c}
	done
	## Once all of the files are updated, we can't just do it as a reinstall.
	## Otherwise, services will go splat, databases will corrupt, elder gods
	## will rend a hole in reality, etc.
	DOTNET_URL=https://download.visualstudio.microsoft.com/download/${DOTNET_PR}/${DOTNET_KEY}/dotnet-runtime-${DOTNET_VERSION}-linux-musl-x64.tar.gz
	DOTNET_VERSION=$(cat /opt/talecaster/etc/dotnet.release)
	DOTNET_PR=$(cat /opt/talecaster/etc/dotnet.pr)
	DOTNET_KEY=$(cat /opt/talecaster/etc/dotnet.key)
	DOTNET_SHA512=$(cat /opt/talecaster/etc/dotnet.sha512)
	TARFILE=/tmp/dotnet.tgz
	if [ -f $TARFILE ]; then
		rm -f $TARFILE
	fi
	wget -O $TARFILE $DOTNET_URL
	## ... but still, let's minimize downtime by downloading before stopping.
	local sha512=$(sha512sum $TARFILE | awk '{print $1}')
	if [ $sha512 != $DOTNET_SHA512 ]; then
		printf 'Upgrade failed! SHA512 does not match.\n'
		exit 2
	fi
	if [ -f /opt/talecaster/id.service ]; then
		service=$(cat /opt/talecaster/id.service)
	fi
	if [ ! -z $service ]; then
		service $service stop
		apk upgrade --no-cache libgcc libstdc++ libc6-compat gcompat
		## This returns 1 if there's no upgrade, which is not an error here.
		tar -C /usr/share/dotnet -oxzf $TARFILE
		CHECK_ERROR $? dotnet_extract
		## Start the service before the long rm
		service $service start
		rm -f $TARFILE
		newver=$(dotnet --info | grep Version | cut -d : -f 2)
		printf 'Upgraded to dotnet runtime %s\n' "$newver"
		exit 0
	else
		## We don't have a defined service, so all bets are off.
		apk upgrade --no-cache libgcc libstdc++ libc6-compat gcompat
		## This returns 1 if there's no upgrade, which is not an error here.
		tar -C /usr/share/dotnet -oxzf $TARFILE
		CHECK_ERROR $? dotnet_extract
		rm -f $TARFILE
		newver=$(dotnet --info | grep Version | cut -d : -f 2)
		printf 'Upgraded to dotnet runtime %s\n' "$newver"
		exit 0
	fi
}

existing_version
check_update
