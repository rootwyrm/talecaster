#!/bin/bash
## deluge/application/deploy.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# COMMERCIAL DISTRIBUTION IN ANY FORM IS EXPRESSLY PROHIBITED WITHOUT
# WRITTEN CONSENT

export app_name="deluge"
export app_license="GPLv3"
export app_url="https://deluge-torrent.org"
export app_git_url="git://deluge-torrent.org/deluge.git"
export app_destdir="/opt/deluge"

export app_svname="deluge"
export app_psname="deluge"

## Ingest library
. /opt/talecaster/lib/deploy.lib.sh

############################################################
## Install configuration files
############################################################
config_checkdir()
{
	test -d /downloads
	if [ $? -ne 0 ]; then
		printf '[FATAL] /downloads is missing!\n'
		exit 1
	fi
	if [[ $(stat -c %u /downloads) != $tcuid ]]; then
		chown $tcuid /downloads
		if [ $? -ne 0 ]; then
			printf '[FATAL] Incorect permissions on /downloads\n'
			exit 1
		fi
	fi
	if [[ $(stat -c %g /downloads) != $tcgid ]]; then
		chgrp $tcgid /downloads
		if [ $? -ne 0 ]; then
			printf '[FATAL] Incorrect permissions on /downloads\n'
			exit 1
		fi
	fi

	test -d /config
	if [ $? -ne 0 ]; then
		printf '[FATAL] /config is missing!\n'
		exit 1
	fi

	test -d /config/ssl
	if [ $? -ne 0 ]; then
		mkdir /config/ssl
		chown $tcuid:$tcgid /config/ssl
		chmod 0700 /config/ssl
	else
		## XXX: SSL perm checks
	fi

	for cfile in XXX_CONFIG_PLACEHOLDER; do
		test -f /config/$cfile
		if [ $? -ne 0 ]; then
			touch /config/$cfile
			chown $tcuid:$tcgid /config/$cfile
		else
			cp /config/$cfile /config/"$cfile".bak
			cat /dev/null > /config/$cfile
			chown $tcuid:$tcgid /config/$cfile
		fi
	done

	test -d /var/run/$app_name
	if [ $? -ne 0 ]; then
		mkdir /var/run/$app_name
		chown $tcuid:$tcgid /var/run/$app_name
	fi
}

############################################################
## Application Install
############################################################
