#!/bin/sh
######################################################################
#
# Copyright 2017-* TaleCaster and Contributors
# All rights reserved
#
# LICENSE PLACEHOLDER
#
######################################################################

######################################################################
# Utility Functions
######################################################################

log_setup()
{
	if [ ! -d /release/log ]; then
		mkdir /release/log
	fi

	if [ -z ${LOGFILE} ]; then
		LOGFILE="/release/log/release-$(date +%d-%m-%Y)"
	fi
}

log()
{
	## use syslog format.
	echo '`date` `hostname -s` $0: $1' | tee -a ${LOGFILE}
}

log_warning()
{
	## use syslog format.
	echo '`date` `hostname -s` $0: [WARN] $1' | tee -a ${LOGFILE}
}

log_error()
{
	## use syslog format.
	echo '`date` `hostname -s` $0: [ERROR] $1' | tee -a ${LOGFILE}
	exit $2
}
