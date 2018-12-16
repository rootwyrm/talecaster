#!/bin/bash
## tc_deluge/application/build/10.libtorrent.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

export BUILDNAME="libtorrent"

## Build
export vbpkg="libtorrent_build"
export vbpkg_content="gcc g++ autoconf libtool automake make gettext-dev openssl-dev boost-dev python2-dev"
## Runtime
export vrpkg="libtorrent"
export vrpkg_contents="python2 boost boost-python"

export curl_cmd="/usr/bin/curl --tlsv1.2 -L --silent"
export libtorrentv="1.2.0-RC2"

install_runtime()
{
	############################################################
	## Install runtime packages first.
	############################################################
	echo "$(date '+%b %d %H:%M:%S') [BUILD] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content > /dev/null 2>&1
	CHECK_ERROR $? $vrpkg

	## Sitecustomize installation
	cp /opt/talecaster/python/sitecustomize.py /usr/lib/python2.7/site-packages/sitecustomize.py
	CHECK_ERROR $? "sitecustomize"

	if [ ! -f /usr/lib/python2.7/site-packages/sitecustomize.py ]; then
		echo "$(date '+%b %d %H:%M:%S') [FATAL] Missing python2.7/site-packages/sitecustomize.py!"
		exit 2
	fi
}

install_buildpkg()
{
	############################################################
	## Install our build packages.
	############################################################
	printf '%s [BUILD] Entering libtorrent-rasterbar build phase...\n' $(date '+%b %d %H:%M:%S')
	printf '%s [libtorrent] Installing libtorrent-rasterbar build packages...\n' $(date '+%b %d %H:%M:%S')
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content
	CHECK_ERROR $? $vbpkg
}

build_libtorrent()
{
	printf '%s [libtorrent] Retrieving $libtorrentv\n' $(date '+%b %d %H:%M:%S')
	cd /opt/talecaster/build
	$curl_cmd https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_2-RC2/libtorrent-rasterbar-1.2.0-RC2.tar.gz > libtorrent-rasterbar-$libtorrentv.tar.gz
	tar xpfz libtorrent-rasterbar-$libtorrentv.tar.gz
	rm libtorrent-rasterbar-$libtorrentv.tar.gz
	cd libtorrent-rasterbar-1.2.0

	# XXX: Need to use a log function in deploy.lib.sh
	printf '%s [libtorrent] Running configure...\n' $(date '+%b %d %H:%M:%S')
	LIBTORRENT_PREFIX=/usr/local
	./configure --prefix=/usr/local --with-boost --with-boost-python --with-libiconv --enable-python-binding
	CHECK_ERROR $? "libtorrent_configure"
	printf '%s [libtorrent] configure complete.\n' $(date '+%b %d %H:%M:%S')
	
	printf '%s [libtorrent] Compiling...\n' $(date '+%b %d %H:%M:%S')
	make
	CHECK_ERROR $? "libtorrent_build"
	printf '%s [libtorrent] Compile complete.\n' $(date '+%b %d %H:%M:%S')
	
	printf '%s [libtorrent] Installing...\n' $(date '+%b %d %H:%M:%S')
	make install
	CHECK_ERROR $? "libtorrent_install"
	printf '%s [libtorrent] Installation complete.\n' $(date '+%b %d %H:%M:%S')
}

clean_libtorrent()
{
	## Clean up files we don't need.
	printf '%s [libtorrent] Cleaning up build...\n' $(date '+%b %d %H:%M:%S')
	make clean
	cd /root
	rm -rf /opt/talecaster/build/libtorrent-rasterbar-$libtorrentv
	CHECK_ERROR $? "libtorrent_clean_delete_source"
	printf '%s [libtorrent] Build cleaned up.\n' $(date '+%b %d %H:%M:%S')


	printf '%s [libtorrent] Removing build-only packages...\n' $(date '+%b %d %H:%M:%S')
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "libtorrent_clean_apk"
}

install_runtime
install_buildpkg
build_libtorrent
clean_libtorrent

printf '%s [libtorrent] Build and install of libtorrent $libtorrentv complete.' $(date '+%b %d %H:%M:%S')
exit 0

