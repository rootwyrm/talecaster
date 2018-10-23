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
# FreeBSD Functions
######################################################################

TARGET_ARCH='needs-set-by-config'

## Config needs to set these

## Make non-empty to override build-avoidance
FREEBSD_FORCE_BUILDKERNEL=""
FREEBSD_FORCE_BUILDWORLD=""

## Keep the obj tree separate from /usr/obj
SRCCONF=/dev/null
__MAKE_CONF=/dev/null

## Set up our objdir
freebsd_default_makeobjdirprefix()
{
	if [ -z "$MAKEOBJDIRPREFIX" ]; then
		MAKEOBJDIRPREFIX=${WORKDIR}/obj
	fi
	export MAKEOBJDIRPREFIX
}

freebsd_src_select_revision()
{
	if [ -z ${REVISION} ]; then
		log_error "freebsd_src_select_revision() called without revision!" 200
	fi
	## Building for a specific revision
	log "Selected revision r${REVISION}"
	zfs_create ${SRCDIR}/${REVISION}
	## NOTE: error handling is in zfs_create
	$SVNBIN co -r ${REVISION} ${SRCDIR}/${REVISION}/
	if [ $? -ne 0 ]; then
		log_error "Error checking out revision r${REVISION}" 40
	fi
}
