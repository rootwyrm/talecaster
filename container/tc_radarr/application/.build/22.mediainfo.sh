#!/bin/bash
## application/build/20.libzen.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT.

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

test -d /opt/talecaster/build
if [ $? -ne 0 ]; then
	mkdir -p /opt/talecaster/build
fi
bldroot="/opt/talecaster/build"

## XXX: Has to be in functions.
build_mediainfo()
{
	local ver="0.7.97"
	vb_mediainfo="vp_mediainfo_build"
	vb_mediainfo_content="gcc g++ autoconf libtool automake gettext-dev cmake make linux-headers sqlite-dev openssl-dev curl-dev libmms-dev"
	vr_mediainfo="vp_libzen_run"
	vr_mediainfo_content="libmms curl python2 gettext python2 sqlite openssl"

	/sbin/apk --no-cache add --virtual $vr_mediainfo $vr_mediainfo_content
	/sbin/apk --no-cache add --virtual $vb_mediainfo $vb_mediainfo_content

	cd $bldroot
	echo "[BUILD] (MediaInfo) Downloading..."
	curl -L https://sourceforge.net/projects/mediainfo/files/source/mediainfo/$ver/mediainfo_$ver.tar.gz/download | tar xz
	cd MediaInfo/Project/GNU/CLI
	echo "[BUILD] (MediaInfo) Configuring..."
	./autogen.sh 
	./configure --enable-shared --prefix=/usr/local
	check_error $? "mediainfo_autogen"
	echo "[BUILD] (MediaInfo) Building..."
	make
	make install
	check_error $? "mediainfo_build"
	echo "[BUILD] (MediaInfo) Cleaning..."
	make distclean
	cd /opt/talecaster/build
	rm -rf MediaInfo

	## Clean out afterward
	/sbin/apk --no-cache del $vb_mediainfo
}

build_mediainfo
