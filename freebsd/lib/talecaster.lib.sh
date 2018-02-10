#!/bin/sh
# $FreeBSD
#
# Copyright (C) 2017-* Phillip R. Jaenke and contributors
# All rights reserved
#
# TaleCaster Shell Function Library

export logdate=$(date +"%b %d %H:%m:%S")

## Log to /opt/talecaster/log/talecaster.log
log_tc()
{
	if [ -z $4 ]; then
		local LOGFILE="/opt/talecaster/log/talecaster.log"
	else
		local LOGFILE="/opt/talecaster/log/$4"
	fi

	case $2 in 
		m|M)
			## Informational Message Only
			echo "$logdate $1" >> $LOGFILE
			;;
		n|N)
			## Notice
			echo "$logdate [NOTICE] $1" >> $LOGFILE
			;;
		w|W)
			## Warning
			echo "$logdate [WARN] $1" >> $LOGFILE
			;;
		e|E)
			## Error
			echo "$logdate [ERROR] $1" >> $LOGFILE
			exit $3
			;;
	esac
}
