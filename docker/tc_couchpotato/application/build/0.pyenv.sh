#!/bin/bash
## sickrage/application/build/0.pyenv.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT 
# EXPRESS WRITTEN CONSENT.

######################################################################
## Function Import and Setup
######################################################################

. /opt/talecaster/lib/deploy.lib.sh

buildname="pyenv_couchpotato"

## Build
vbpkg="vp_python_couchpotato_build"
vbpkg_content="musl-dev python-dev libffi-dev openssl-dev gcc sqlite-dev libxml2-dev libxslt-dev"
## Runtime
vrpkg="vp_python_couchpotato"
vrpkg_content="unrar libffi libxslt libxml2 sqlite"

url_pip="https://bootstrap.pypa.io/get-pip.py"

curl_cmd="/usr/bin/curl --tlsv1.2 --cert-status --progress-bar"
pycmd="/usr/bin/python"
pip_pre="--prefix /usr/local"
pip_args="--prefix /usr/local --quiet --no-cache-dir --exists-action i"

## sitecustomize check
if [ ! -f /usr/lib/python2.7/site-packages/sitecustomize.py ]; then
	echo "$buildname: [FATAL] Missing python2.7/site-packages/sitecustomize.py!"
	exit 2
fi

######################################################################
## Install runtime packages first
######################################################################
echo "[BUILD] Installing runtime dependencies as $vrpkg"
/sbin/apk --no-cache add --virtual $vrpkg $vrpkg_content
check_error $? $vrpkg

######################################################################
## Install PIP
######################################################################
$curl_cmd $url_pip > /opt/talecaster/pip.py
check_error $? "pip fetch"
$pycmd /opt/talecaster/pip.py $pip_pre
if [ $? -ne 0 ]; then
	RC=$?
	echo "$buildname: [FATAL] pip bootstrap failure! RC $RC"
	exit $RC
fi

######################################################################
## PIP functionality tests
######################################################################
/usr/local/bin/pip list > /dev/null
check_error $? "pip list functional test"

######################################################################
## Build Phase
######################################################################
echo "[BUILD] Installing build packages as $vbpkg"
/sbin/apk --no-cache add --virtual $vbpkg $vbpkg_content
check_error $? $vbpkg

## Cheetah
printf '[BUILD] Building and installing lxml\n'
/usr/local/bin/pip install $pip_args lxml
check_error $? lxml 

## pyOpenSSL
printf '[BUILD] Building and installing pyOpenSSL\n'
/usr/local/bin/pip install $pip_args pyOpenSSL
check_error $? pyOpenSSL

## Validate modules
pip list --format=legacy | awk '{print $1}' > /tmp/pip.list
printf '[BUILD] Validating module installation\n'
printf 'Python [MODULES]: '
for pydep in \
	pip lxml pyOpenSSL setuptools; do
	grep -i $pydep /tmp/pip.list > /dev/null
	if [ $? -eq 0 ]; then
		printf '%s ' "$pydep"
	else
		printf '\n[FATAL] %s did not install!' "$pydep"
		exit 2
	fi
	printf '\n'
done
rm /tmp/pip.list

printf '[BUILD] Cleaning up %s\n' "$vbpkg"
/sbin/apk --no-cache del $vbpkg

echo ""
echo "[BUILD] $0 completed successfully!"
