#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## application/build/05.libgdiplus.sh

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/talecaster.lib.sh

export BUILDNAME="libgdiplus"

## Build
export vbpkg="libgdiplus_build"
export vbpkg_content="gcc g++ autoconf libtool automake gettext-dev make musl-dev binutils libexif-dev pango-dev giflib-dev libjpeg-turbo-dev tiff-dev"
## Runtime
export vrpkg="libgdiplus_run"
export vrpkg_content="linux-headers libgcc libstdc++ libexif pango giflib libjpeg-turbo tiff"

export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"
export libgdiplusv="6.0.5"

install_runtime()
{
	######################################################################
	## Install runtime packages first.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [BUILD] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg
}

install_buildpkg()
{
	######################################################################
	## Install our build packages.
	######################################################################
	printf '%s [BUILD] Entering Mono build phase...\n' $(date '+%b %d %H:%M:%S')
	printf '%s [MONO] Installing build packages...\n' $(date '+%b %d %H:%M:%S')
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content
	CHECK_ERROR $? $vbpkg
}

build_libgdiplus()
{
	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Retrieving libgdiplus $libgdiplusv"
	if [ ! -d /usr/local/src ]; then
		mkdir -p /usr/local/src
	fi
	cd /usr/local/src
	$curl_cmd https://github.com/mono/libgdiplus/archive/refs/tags/$libgdiplusv.tar.gz > libgdiplus-$libgdiplusv.tar.gz
	tar xf libgdiplus-$libgdiplusv.tar.gz
	rm libgdiplus-$libgdiplusv.tar.gz
	cd libgdiplus-$libgdiplusv

	echo "$(date '+%b %d %H:%M:%S') [MONO] Configuring..."
	## XXX: This gets very complicated. Do not touch.
	LIBGDIPLUS_PREFIX=/usr/local
	./autogen.sh \
		--prefix=$LIBGDIPLUS_PREFIX \
		--sysconfdir=/usr/local/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--with-pango
	CHECK_ERROR $? "libgdiplus_configure"
	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] autogen.sh complete."

	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Building..."
	make 
	CHECK_ERROR $? "libgdiplus_build"
	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Build complete."

	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Doing make install..."
	make install
	CHECK_ERROR $? "libgdiplus_install"
	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] make install complete"
}

clean_libgdiplus()
{
	######################################################################
	## Clean up after ourselves, because seriously, this is batshit huge.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Cleaning up build."
	make clean
	cd /root
	rm -rf /usr/local/src/libgdiplus-$libgdiplusv
	CHECK_ERROR $? "libgdiplus_clean_delete_source"
	## Strip to get the size back down
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "libgdiplus_clean_$vbpkg"
}

install_runtime
install_buildpkg
build_libgdiplus
clean_libgdiplus

echo "$(date '+%b %d %H:%M:%S') [libgdiplus] Build and install of libgdiplus $libgdiplus complete."
exit 0 
