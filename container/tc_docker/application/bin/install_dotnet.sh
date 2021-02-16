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

DOTNET_VERSION=5.0.3

function download()
{
	export TARFILE=/tmp/dotnet.tgz
	wget -O $TARFILE https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz
	CHECK_ERROR $? retrieve_dotnet
}

function install()
{
	mkdir -p /usr/share/dotnet
	tar -C /usr/share/dotnet -oxzf $TARFILE
	CHECK_ERROR $? dotnet_extract
	ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
	rm -f $TARFILE
	apk update
	apk add --no-cache libc6-compat gcompat
}

download
install
dotnet --info
if [ $? -ne 0 ]; then
	printf 'dotnet runtime installation failed!\n'
	exit 2
fi
