#!/bin/bash
## application/build/30.sonarr.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT.

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

buildname="sonarr_install"

## Build
vbpkg=""
vbpkg_content=""
## Runtime
vrpkg="vp_NzbDrone"
vrpkg_content="nodejs libgcc"

## TODO: mono test
## TODO: libmediainfo and mediainfo tests

sonarr_site="download.sonarr.tv"
sonarr_tree="v2"
sonarr_file="NzbDrone.master.tar.gz"

curl_cmd="/usr/bin/curl --tlsv1.2 --progress-bar -L"

echo "[BUILD] Installing prerequisites..."
# XXX: Work around weird apk bug..
/sbin/apk info > /dev/null
/sbin/apk update > /dev/null
/sbin/apk add --no-cache --virtual $vrpkg $vrpkg_content

echo "[BUILD] Retrieving Sonarr..."
cd /opt/talecaster
$curl_cmd https://$sonarr_site/$sonarr_tree/master/latest/NzbDrone.master.tar.gz | tar xz
check_error $? nzbdrone_retrieve

## Results in ./NzbDrone
if [ ! -d /opt/talecaster/NzbDrone ]; then
	echo "[BUILD] Sonarr retrieval failed!"
	exit 1
fi
cd /opt/talecaster/NzbDrone

## Perform an update, just in case.
$(which mono) ./NzbDrone.Update/NzbDrone.Update.exe
check_error $? nzbdrone_update

echo "[BUILD] Sonarr installed."
exit 0
