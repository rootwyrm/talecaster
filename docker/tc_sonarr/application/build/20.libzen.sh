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
build_libzen()
{
	local ver="0.4.35"
	vb_libzen="vp_libzen_build"
	vb_libzen_content="gcc g++ autoconf libtool automake gettext-dev cmake make linux-headers sqlite-dev openssl-dev"
	vr_libzen="vp_libzen_run"
	vr_libzen_content="python2 gettext python2 sqlite openssl"

	/sbin/apk --no-cache add --virtual $vr_libzen $vr_libzen_content
	/sbin/apk --no-cache add --virtual $vb_libzen $vb_libzen_content

	cd $bldroot
	echo "[BUILD] (ZenLib) Downloading..."
	curl -L https://github.com/MediaArea/ZenLib/archive/v$ver.tar.gz | tar xz 
	cd ZenLib-$ver/Project/GNU/Library
	echo "[BUILD] (ZenLib) Configuring..."
	./autogen.sh 
	echo "Autogen done"
	./configure --enable-shared --prefix=/usr/local
	check_error $? "libzen_autogen"
	echo "[BUILD] (ZenLib) Building..."
	echo $PWD
	make
	make install
	check_error $? "libzen_build"
	echo "[BUILD] (ZenLib) Cleaning..."
	make clean
	cd /opt/talecaster/build
	rm -rf ZenLib-$ver

	## Clean out afterward
	/sbin/apk --no-cache del $vb_libzen
}

build_libzen
