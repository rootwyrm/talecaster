#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## application/build/10.mono.sh

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/talecaster.lib.sh

export BUILDNAME="mono"

## Build
export vbpkg="mono_build"
export vbpkg_content="git gcc g++ autoconf libtool automake gettext-dev cmake make openssl-dev sqlite-dev ninja inotify-tools-dev musl-dev binutils"
## Runtime
export vrpkg="mono_run"
export vrpkg_content="curl gettext inotify-tools linux-headers python3 openssl sqlite pax-utils libgcc libstdc++ ca-certificates"

export curl_cmd="/usr/bin/curl --tlsv1.2 --cert-status -L --silent"
export monov="6.12.0.122"

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

build_mono()
{
	echo "$(date '+%b %d %H:%M:%S') [MONO] Retrieving $monov"
	if [ ! -d /usr/local/src ]; then
		mkdir -p /usr/local/src
	fi
	cd /usr/local/src
	$curl_cmd https://download.mono-project.com/sources/mono/mono-$monov.tar.xz > mono-$monov.tar.xz
	xzcat mono-$monov.tar.xz | tar xf -
	rm mono-$monov.tar.xz
	cd mono-$monov

	echo "$(date '+%b %d %H:%M:%S') [MONO] Configuring..."
	## XXX: This gets very complicated. Do not touch.
	MONO_PREFIX=/usr/local
	./configure \
		--prefix=$MONO_PREFIX \
		--sysconfdir=/usr/local/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--localstatedir=/var \
		--enable-small-config \
		--enable-dependency-tracking \
		--with-sgen=yes \
		--without-x  \
		--enable-ninja \
		--with-mcs-docs=no 
		#--with-bitcode=yes \
	CHECK_ERROR $? "mono_configure"
	echo "$(date '+%b %d %H:%M:%S') [MONO] autogen.sh complete."

	echo "$(date '+%b %d %H:%M:%S') [MONO] Building..."
	make 
	CHECK_ERROR $? "mono_build"
	echo "$(date '+%b %d %H:%M:%S') [MONO] Build complete."

	echo "$(date '+%b %d %H:%M:%S') [MONO] Doing make install..."
	make install
	CHECK_ERROR $? "mono_install"
	echo "$(date '+%b %d %H:%M:%S') [MONO] make install complete"
}

clean_mono()
{
	## Strip binaries too.
	echo "$(date '+%b %d %H:%M:%S') [MONO] strip-ing binaries..."
	strip $MONO_PREFIX/bin/mono

	## Clean up files we don't need.
	echo "$(date '+%b %d %H:%M:%S') [MONO] Cleaning additional unneeded files..."
	find . /usr/local/lib -name *.la -exec rm -f {} \;
	CHECK_ERROR $? "mono_clean_la"
	find . /usr/local/lib -name Mono.Security.Win32* -exec rm -f {} \;
	CHECK_ERROR $? "mono_clean_security_win32"
	find . /usr/local/lib -name libMonoSupportW* -exec rm -f {} \;
	CHECK_ERROR $? "mono_clean_monoSupportWin"
	echo "$(date '+%b %d %H:%M:%S') [MONO] Done cleaning."

	######################################################################
	## Clean up after ourselves, because seriously, this is batshit huge.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [MONO] Cleaning up build."
	make clean
	cd /root
	rm -rf /usr/local/src/mono-$monov
	CHECK_ERROR $? "mono_clean_delete_source"
	## Strip to get the size back down
	find /usr/local -type f -exec strip {} \; > /dev/null
	CHECK_ERROR $? "mono_strip_installed"
	/sbin/apk --no-cache del mono_build
	CHECK_ERROR $? "mono_clean_apk"
}

install_runtime
install_buildpkg
build_mono
clean_mono

echo "$(date '+%b %d %H:%M:%S') [MONO] Build and install of $monov complete."
exit 0 
