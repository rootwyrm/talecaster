#!/bin/bash
## lazylibrarian/application/deploy.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# 
# COMMERCIAL DISTRIBUTION IN ANY FORM IS EXPRESSLY PROHIBITED WITHOUT
# WRITTEN CONSENT.

export app_name="lazylibrarian"
export app_license="GPLv3"
export app_url="https://github.com/DobyTang/LazyLibrarian"
export app_git_url="https://github.com/DobyTang/LazyLibrarian.git"
export app_destdir="/opt/lazylibrarian"

#export app_cmd="/usr/bin/python /opt/headphones/Headphones.py"
export app_svname="lazylibrarian"
export app_psname="LazyLibrarian.py"

## Ingest library
. /opt/talecaster/lib/deploy.lib.sh

######################################################################
## Install configuration files
######################################################################
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
			echo "[FATAL] Incorrect permissions on /downloads"
			exit 1
		fi
	fi
	if [[ $(stat -c %g /downloads) != $tcgid ]]; then
		chgrp $tcgid /downloads
		if [ $? -ne 0 ]; then
			echo "[FATAL] Incorrect permissions on /downloads"
			exit 1
		fi
	fi

	test -d /config
	if [ $? -ne 0 ]; then
		echo "[FATAL] /config is missing!"
		exit 1
	fi
	test -d /config/ssl
	if [ $? -ne 0 ]; then
		mkdir /config/ssl
		chown $tcuid:$tcgid /config/ssl
		chmod 0700 /config/ssl
	else
		if [[ $(stat -c %u /config/ssl) != $tcuid ]]; then
			chown -R $tcuid /config/ssl
			check_error $? "/config/ssl permissions"
		fi
		if [[ $(stat -c %g /config/ssl) != $tcgid ]]; then
			chown -R $tcgid /config/ssl
			check_error $? "/config/ssl permissions"
		fi
		if [[ $(stat -c %a /config/ssl) != '700' ]]; then
			chmod -R 0700 /config/ssl
			check_error $? "/config/ssl permissions"
		fi
	fi

	for cfile in config.ini; do
		test -f /config/$cfile
		if [ $? -ne 0 ]; then
			touch /config/$cfile
		else
			cp /config/$cfile /config/"$cfile".bak
			cat /dev/null > /config/$cfile
		fi
	done

	test -d /var/run/$app_name
	if [ $? -ne 0 ]; then
		mkdir /var/run/$app_name
		chown $tcuid:$tcgid /var/run/$app_name
	fi
}

config_copybase()
{
	## Only has one config file
	export basecfg="/config/config.ini"
	if [[ $(test -f $basecfg) -eq 0 ]]; then
		## Back it up.
		echo "[NOTICE] Backing up your existing $basecfg"
		cp $basecfg "$basecfg".bak
	fi

	cp /opt/talecaster/defaults/config.ini $basecfg
	if [ $? -ne 0 ]; then
		RC=$?
		return $rc
	else
		return 0
	fi 
}

config_update()
{
	## Generate a new API key on initial deployment because reasons.
	conffile="/config/config.ini"
	export NEWAPI=$(/opt/talecaster/python/regenapi.py | cut -d : -f 2)
	sed -i -e "s,^api_key.*,api_key = $NEWAPI," $conffile
	echo "[NOTICE] API Key Regenerated!"
	echo "[NOTICE] New API Key: $NEWAPI"

	sed -i -e "s,^http_host.*,http_host = 0.0.0.0," $conffile

	sed -i -e "s,^verify_ssl_cert*,verify_ssl_cert = 0," $conffile
	sed -i -e "s,^enable_https.*,enable_https = 1," $conffile
	sed -i -e "s,^https_cert.*,https_cert = /config/ssl/"$app_name".crt," $conffile
	sed -i -e "s,^https_key.*,https_key = /config/ssl/"$app_name".key," $conffile

	sed -i -e "s,launch_browser.*,launch_browser = 0," $conffile
	## Be explicit about our git path
	sed -i -e "s,git_path.*,git_path = /usr/bin/git," $conffile
}

######################################################################
## Application Install
######################################################################
application_install()
{
	lazylibrarian_install_bookstrap
}

lazylibrarian_install_bookstrap()
{
	bookstrapurl="https://github.com/warlord0/lazylibrarian.bookstrap.git"
	git clone $bookstrapurl -b master --depth=1 -c $app_destdir/
	if [ $? -ne 0 ]; then
		echo "[WARNING] Error installing bookstrap."
	fi
}

######################################################################
## Execution Phase
######################################################################

ingest_environment
test_deploy

generate_motd
cat /etc/motd

echo "[DEPLOY] Deploying TaleCaster user"
deploy_talecaster_user

deploy_application_git reinst
chown -R $tcuid:$tcgid $app_destdir
application_install

config_checkdir
config_copybase
ssl_ssc_create
config_update

echo "[DEPLOY] Adjusting file ownership"
deploy_tcuser_ownership

runit_linksv

deploy_complete

echo "[DEPLOY] Initial deployment complete."
if [ -f /firstboot ]; then
	rm /firstboot
fi

## Print a double newline for cleanliness
echo " "
echo " " 
