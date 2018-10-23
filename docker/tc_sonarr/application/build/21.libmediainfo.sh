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
build_libmediainfo()
{
	local ver="0.7.97"
	vb_libmediainfo="vp_libmediainfo_build"
	vb_libmediainfo_content="gcc g++ autoconf libtool automake gettext-dev cmake make linux-headers sqlite-dev openssl-dev curl-dev libmms-dev"
	vr_libmediainfo="vp_libzen_run"
	vr_libmediainfo_content="libmms curl python2 gettext python2 sqlite openssl"

	/sbin/apk --no-cache add --virtual $vr_libmediainfo $vr_libmediainfo_content
	/sbin/apk --no-cache add --virtual $vb_libmediainfo $vb_libmediainfo_content

	cd $bldroot
	echo "[BUILD] (LibMediaInfo) Downloading..."
	curl -L https://sourceforge.net/projects/mediainfo/files/source/libmediainfo/$ver/libmediainfo_$ver.tar.gz/download | tar xz
	cd MediaInfoLib/Project/GNU/Library
	echo "[BUILD] (LibMediaInfo) Configuring..."
	./autogen.sh 
	./configure --enable-shared --with-libcurl --with-libmms --prefix=/usr/local
	check_error $? "libmediainfo_autogen"
	echo "[BUILD] (LibMediaInfo) Building..."
	make
	make install
	check_error $? "libmediainfo_build"
	echo "[BUILD] (LibMediaInfo) Cleaning..."
	make distclean
	cd /opt/talecaster/build
	rm -rf LibMediaInfo

	## Clean out afterward
	/sbin/apk --no-cache del $vb_libmediainfo
}

build_libmediainfo
