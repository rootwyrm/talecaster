#!/usr/bin/env bash
################################################################################
# TaleCaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com> and its
# contributors.
# All rights reserved
# 
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/lib/talecaster.lib.sh

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
		else
			LOG "Error occurred in $2 : $1" E $RC
		fi
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
	## Still not really used, always just runs latest...
	relfile="/opt/talecaster/id.release"
	if [ ! -f $relfile ]; then
		release=${release:-"latest"}
	elif [ -f $relfile ]; then
		release=$(cat $relfile)
	fi

	msgfile="/message"
	sed -i -e 's,%RELEASE%,'$release',g' $msgfile
	sed -i -e 's,%APPNAME%,'$appname',g' $msgfile
}

## Check if in firstrun state
function check_firstrun()
{
	if [ -f /firstboot ]; then
		printf ' * TaleCaster: found /firstboot, running initial setup\n'
		return 1
	fi
	if [ -f /factory.reset ]; then
		printf ' * TaleCaster: found /factory.reset, performing reset\n'
		export FACTORY_RESET=1
		return 1
	fi
}

# vim:ft=sh:ts=4:sw=4
