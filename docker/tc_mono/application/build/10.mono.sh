#!/bin/bash
## application/build/10.mono.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

export BUILDNAME="mono"

## Build
export vbpkg="mono_build"
export vbpkg_content="git gcc g++ autoconf libtool automake gettext-dev cmake make openssl-dev ninja"
## Runtime
export vrpkg="mono_run"
export vrpkg_content="curl gettext linux-headers python2 openssl jemalloc pax-utils"

export curl_cmd="/usr/bin/curl --tlsv1.2 --cert-status -L --silent"
export monov="5.10.1.57"

install_runtime()
{
	######################################################################
	## Install runtime packages first.
	######################################################################
	echo "$(date '+%b %d %H:%M:%S') [BUILD] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg

	## sitecustomize check
	cp /opt/talecaster/python/sitecustomize.py /usr/lib/python2.7/site-packages/sitecustomize.py
	CHECK_ERROR $? "sitecutomize"

	if [ ! -f /usr/lib/python2.7/site-packages/sitecustomize.py ]; then
		echo "$buildname: [FATAL] Missing python2.7/site-packages/sitecustomize.py!"
		exit 2
	fi
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
	cd /opt/talecaster/build
	$curl_cmd https://download.mono-project.com/sources/mono/mono-$monov.tar.bz2 > mono-$monov.tar.bz2 
	bunzip2 mono-$monov.tar.bz2
	tar xf mono-$monov.tar
	rm mono-$monov.tar
	cd mono-$monov

	echo "$(date '+%b %d %H:%M:%S') [MONO] Configuring..."
	## XXX: This got a lot more complex to get the size down...
	MONO_PREFIX=/usr/local
	./autogen.sh \
		--prefix=/usr/local --sysconfdir=/usr/local/etc --mandir=/usr/share/man \
		--infodir=/usr/share/info --localstatedir=/var \
		--enable-small-config --with-mcs-docs=no 
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
	rm -rf /opt/talecaster/build/mono-$monov
	CHECK_ERROR $? "mono_clean_delete_source"
	/sbin/apk --no-cache del mono_build
	CHECK_ERROR $? "mono_clean_apk"
}

install_runtime
install_buildpkg
build_mono
clean_mono

echo "$(date '+%b %d %H:%M:%S') [MONO] Build and install of $monov complete."
exit 0 
