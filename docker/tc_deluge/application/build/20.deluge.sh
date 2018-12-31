#!/bin/bash
## tc_deluge/application/build/20.deluge.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

export buildname="deluge"

## Build
export vbpkg="deluge_build"
export vbpkg_content="git gcc g++ libtool libffi-dev gettext-dev openssl-dev boost-dev python2-dev"
## Runtime
export vrpkg="deluge_run"
export vrpkg_content="python2 py2-pip boost boost-python gettext gettext-libs intltool libffi py2-chardet py2-geoip py2-mako py2-markupsafe py2-openssl py2-pillow py2-setuptools py2-simplejson zlib"

export curl_cmd="/usr/bin/curl --tlsv1.2 --cert-status -L --silent"
export delugev="master"

install_runtime()
{
	############################################################
	## Install runtime packages first.
	############################################################
	echo "$(date '+%b %d %H:%M:%S') [BUILD] Installing runtime dependencies as $vrpkg"
	/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content 
	#> /dev/null 2>&1
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
	printf '%s [BUILD] Entering $buildname build phase...\n' $(date '+%b %d %H:%M:%S')
	printf '%s [$buildname] Installing $buildname build packages...\n' $(date '+%b %d %H:%M:%S')
	/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content
	CHECK_ERROR $? $vbpkg
}

build_deluge()
{
	## Use pip to install the stuff we can't.
	echo "DEBUG: ${buildname}"
	printf '%s [%s] Installing packages via pip...\n' "$(date '+%b %d %H:%M:%S')" $buildname
	for p in twisted[tls] pyxdg slimit notify; do
		pip install $p
		CHECK_ERROR $? "pip_$p"
	done
	
	printf '%s [$buildname] Retrieving $buildname $delugev\n' $(date '+%b %d %H:%M:%S')
	cd /opt/talecaster/build
	git clone git://deluge-torrent.org/deluge.git
	cd deluge
	echo ${PWD}
	echo ${CWD}

	# XXX: Need to use a log function in deploy.lib.sh
	printf '%s [$buildname] Running configure...\n' $(date '+%b %d %H:%M:%S')

	CHECK_ERROR $? "deluge_configure"
	printf '%s [$buildname] configure complete.\n' $(date '+%b %d %H:%M:%S')
	
	printf '%s [%s] Compiling...\n' "$(date '+%b %d %H:%M:%S')" $buildname
	python setup.py build 
	CHECK_ERROR $? "deluge_build"
	printf '%s [%s] Compile complete.\n' "$(date '+%b %d %H:%M:%S')" $buildname
	
	printf '%s [%s] Installing...\n' "$(date '+%b %d %H:%M:%S')" $buildname
	python setup.py install
	CHECK_ERROR $? ""$buildname"_install"
	printf '%s [%s] Installation complete.\n' "$(date '+%b %d %H:%M:%S')" $buildname
}

clean_deluge()
{
	## Clean up files we don't need.
	printf '%s [$buildname] Cleaning up build...\n' $(date '+%b %d %H:%M:%S')
	python setup.py clean -a
	cd /root
	rm -rf /opt/talecaster/build/$buildname
	CHECK_ERROR $? "'$buildname'_clean_delete_source"
	printf '%s [$buildname] Build cleaned up.\n' $(date '+%b %d %H:%M:%S')


	printf '%s [$buildname] Removing build-only packages...\n' $(date '+%b %d %H:%M:%S')
	/sbin/apk --no-cache del $vbpkg
	CHECK_ERROR $? "'$buildname'_clean_apk"
}

install_runtime
install_buildpkg
build_deluge
clean_deluge

printf '%s [$buildname] Build and install of deluge complete.' "$(date '+%b %d %H:%M:%S')"
exit 0

