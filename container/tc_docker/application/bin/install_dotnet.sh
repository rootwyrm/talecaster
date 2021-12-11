#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

. /opt/talecaster/lib/talecaster.lib.sh

DOTNET_VERSION=$(cat /opt/talecaster/etc/dotnet.release)
DOTNET_SHA512=$(cat /opt/talecaster/etc/dotnet.sha512)

function download()
{
	export TARFILE=/tmp/dotnet.tgz
	printf 'Downloading ${DOTNET_VERSION}... \n'
	wget -q -O $TARFILE https://dotnetcli.azureedge.net/dotnet/Runtime/${DOTNET_VERSION}/dotnet-runtime-${DOTNET_VERSION}-linux-musl-x64.tar.gz
	CHECK_ERROR $? retrieve_dotnet
	local sha512=$(sha512sum $TARFILE | awk '{print $1}')
	if [ ${sha512} != ${DOTNET_SHA512} ]; then
		printf '[ERROR] Checksum mismatch!\n'
		exit 255
	fi
}

function install()
{
	mkdir -p /usr/share/dotnet
	tar -C /usr/share/dotnet -oxzf $TARFILE
	CHECK_ERROR $? dotnet_extract
	ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
	rm -f $TARFILE
	apk update
	apk add --no-cache libgcc libstdc++ libc6-compat gcompat
}

download
install
dotnet --info
if [ $? -ne 0 ]; then
	printf 'dotnet runtime installation failed!\n'
	exit 2
fi
