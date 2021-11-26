#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# tc_docker/application/lib/talecaster.lib.sh

export basedir="/opt/talecaster/defaults"
export svdir="/etc/service"

## Logging function
function LOG()
{
	logfile=${logfile:-"/var/log/talecaster.log"}
	if [ ! -f $logfile ]; then
		touch $logfile
	fi
	case $2 in
		F*|f*)
			## Fatal condition
			RC=${3:-"255"}
			printf '%s [FATAL] %s %s\n' "$(date -Iseconds)" "$1" "$3" | tee -a $logfile
			exit $RC
			;;
		E*|e*)
			## Error condition
			if [ -z $3 ]; then
				## An error code was pushed as well.
				RC=$3
				printf '%s [ERROR] %s %s\n' "$(date -Iseconds)" "$1" "$3" | tee -a $logfile
			else
				printf '%s [ERROR] %s\n' "$(date -Iseconds)" "$1" | tee -a $logfile
			fi
			;;
		W*|w*)
			## Warn condition
			printf '%s [WARN] %s\n' "$(date -Iseconds)" "$1" | tee -a $logfile
			;;
		N*|n*)
			## Notice condition
			printf '%s [NOTICE] %s\n' "$(date -Iseconds)" "$1" | tee -a $logfile
			;;
		D*|d*)
			## Debug messages only go to the logfile.
			printf '%s %s\n' "$(date -Iseconds)" "$1" >> $logfile
			;;
		*)
			## All others
			#printf '%s %s\n' "$(date -Iseconds)" "$1" | tee -a $logfile
			echo "$(date -Iseconds) $1" | tee -a $logfile
			;;
	esac
}

## Check return code
function CHECK_ERROR()
{
	if [ $1 -ne 0 ]; then
		RC=$1
		if [ -z $2 ]; then
			LOG "Error occurred in unknown location" E $RC
			exit $RC
		else
			LOG "Error occurred in $2 : $1" E $RC
			exit $RC
		fi
	else
		return 0
	fi
}

## Load all of our configuration files, in order. Last in wins.
function load_config()
{
	for cf in /.dockerenv /.dockerinit \
		/talecaster/config/talecaster.conf \
		/talecaster/config/user.conf ; do
		if [ -s $cf ]; then
			. $cf
		fi
	done

	## Load in application data as well
	if [ -f /opt/talecaster/id.service ]; then
		export APPNAME=$(cat /opt/talecaster/id.service)
		if [ -d /opt/$APPNAME ]; then
			export appbase="/opt/${APPNAME}"
		fi
	else
		export APPNAME=${APPNAME:-"base"}
	fi
	if [ -f /opt/talecaster/id.provides ]; then
		export SERVICE=$(cat /opt/talecaster/id.provides)
	else
		export SERVICE=${SERVICE:-"none"}
	fi
}

## Load python virtualenv if the container needs one.
function load_pyenv()
{
	if [ -d /opt/talecaster/pyenv ]; then
		if [ -f /opt/talecaster/pyenv/bin/activate ]; then
			. /opt/talecaster/pyenv/bin/activate
		else
			LOG "Container Python environment not found" E 255
		fi
	fi
}

## Message generator
function generate_message()
{
	relfile="/opt/talecaster/id.release"
	if [ ! -f $relfile ]; then
		release=${release:-"latest"}
	elif [ -f $relfile ]; then
		release=$(cat $relfile)
	fi

	msgfile="/message"
	if [ ! -f /message ]; then
		cp /opt/talecaster/etc/message.tpl $msgfile
	fi
	sed -i -e 's,%RELEASE%,'$release',g' $msgfile
	sed -i -e 's,%APPNAME%,'$appname',g' $msgfile
}

## Check if in firstrun state
function check_firstrun()
{
	if [ -f /firstboot ]; then
		printf '\n'
		printf ' * TaleCaster: found /firstboot, running initial setup\n'
		export FIRSTBOOT=1
	fi
	if [ -f /factory.reset ]; then
		printf ' * TaleCaster: found /factory.reset, performing reset\n'
		export FACTORY_RESET=1
	fi
}

## Deploy our user
function deploy_talecaster_user()
{
	## Defaults are based on the reference original architecture and set
	## by the environment.
	## Defaults are talecaster(30000):media(30000)
	## NOTE: Must be below 65534 due to musl limitations. AD environments
	## should set and use the uidNumber and gidNumber values.
	tcuid=${tcuid:="30000"}
	tcgid=${tcgid:="30000"}
	tcuser=${tcuser:="talecaster"}
	tcgroup=${tcgroup:="media"}

	printf 'TaleCaster user is %s[%s]:%s[%s]\n' "$tcuser" "$tcuid" "$tcgroup" "$tcgid"
	grep $tcgid /etc/group > /dev/null
	if [ $? -ne 0 ]; then
		printf 'Adding %s as gid %s\n' "$tcgroup" "$tcgid"
		addgroup -g $tcgid $tcgroup
		CHECK_ERROR $? addgroup
	fi
	grep $tcuser /etc/passwd > /dev/null
	if [ $? -ne 0 ]; then
		printf 'Adding %s as uid %s\n' "$tcuser" "$tcuid"
		adduser -h /home/$tcuser -g "TaleCaster User" -u $tcuid -G $tcgroup -D -s /bin/bash $tcuser
		CHECK_ERROR $? adduser
	fi
}

## Fix user ownership
function user_ownership()
{
	## Defaults are based on the reference original architecture and set
	## by the environment.
	## Defaults are talecaster(30000):media(30000)
	## NOTE: Must be below 65534 due to musl limitations. AD environments
	## should set and use the uidNumber and gidNumber values.
	tcuid=${tcuid:="30000"}
	tcgid=${tcgid:="30000"}
	tcuser=${tcuser:="talecaster"}
	tcgroup=${tcgroup:="media"}

	chown -R $tcuid:$tcgid /home/$tcuser
	CHECK_ERROR $? chown_home
	chown -R $tcuid:$tcgid /talecaster/config
	CHECK_ERROR $? chown_config

	if [ ! -z $appbase ]; then
		if [ -d $appbase ]; then
			chown -R $tcuid:$tcgid $appbase
			CHECK_ERROR $? chown_appbase
		fi
	fi
}

# vim:ft=sh:ts=4:sw=4
