#!/bin/bash
## headphones/application/deploy.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# 
# COMMERCIAL DISTRIBUTION IN ANY FORM IS EXPRESSLY PROHIBITED WITHOUT
# WRITTEN CONSENT.

export app_name="couchpotato"
export app_license="GPLv3"
export app_url="https://github.com/CouchPotato/CouchPotatoServer"
export app_git_url="https://github.com/CouchPotato/CouchPotatoServer.git"
export app_destdir="/opt/couchpotato"

#export app_cmd="/usr/bin/python /opt/headphones/Headphones.py"
export app_svname="couchpotato"
export app_psname="CouchPotato.py"

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

	for cfile in settings.conf; do
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
	export basecfg="/config/settings.conf"
	if [[ $(test -f $basecfg) -eq 0 ]]; then
		## Back it up.
		echo "[NOTICE] Backing up your existing $basecfg"
		cp $basecfg "$basecfg".bak
	fi

	cp /opt/talecaster/defaults/settings.conf $basecfg
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
	conffile="/config/settings.conf"
	export NEWAPI=$(/opt/talecaster/python/regenapi.py | cut -d : -f 2)
	sed -i -e "s,^api_key.*,api_key = $NEWAPI," $conffile
	echo "[NOTICE] API Key Regenerated!"
	echo "[NOTICE] New API Key: $NEWAPI"

	sed -i -e "s,^ssl_cert.*,ssl_cert = /config/ssl/"$app_name".crt," $conffile
	sed -i -e "s,^ssl_key.*,ssl_key = /config/ssl/"$app_name".key," $conffile

	sed -i -e "s,launch_browser.*,launch_browser = False," $conffile
	## Be explicit about our git path
	sed -i -e "s,git_command.*,git_command = /usr/bin/git," $conffile

	## Set up our manage (which we extracted to insert clean.)
	cat << EOF > $conffile
[manage]
startup_scan = True
library_refresh_interval = 24
cleanup = True
enabled = True
library = /media/movies
EOF
	## Configure our renamer with reasonable defaults
	cat << EOF > $conffile
[renamer]
file_name = <thename><cd>.<ext>
next_on_failed = True
default_file_action = move
ntfs_permission = False
check_space = True
nfo_name = <filename>.orig.<ext>
from = /downloads/movies/
foldersep = 
to = /media/movies
cleanup = True
unrar_modify_date = False
move_leftover = False
rename_nfo = True
folder_name = <namethe> (<year>)
run_every = 1
file_action = link
replace_doubles = True
unrar_path = /usr/bin/unrar
enabled = True
unrar = True
separator = 
force_every = 2
remove_lower_quality_copies = True
EOF

}

######################################################################
## Application Install
######################################################################
application_install()
{
	## XXX: Just a placeholder
	test -d /opt/couchpotato
	if [ $? -eq 0 ]; then
		echo "[FATAL] Found existing CouchPotato installation!"
		exit 1
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
