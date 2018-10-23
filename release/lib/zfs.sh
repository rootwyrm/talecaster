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
# ZFS Functions
######################################################################

zfs_scratch_refresh()
{
	if [ ! -d /release/scratch ]; then
		## we're missing the scratch directory?!
		zfs create release/scratch
		if [ $? -ne 0 ]; then
			log_error "Failed to setup /release/scratch!" 50
		fi
	else
		## check our snapshots.
		ls /release/scratch/.zfs/snapshot > /tmp/${BUILDID}.snap
		grep ${BUILDID} /tmp/${BUILDID}.snap
		if [ $? -eq 0 ]; then
			## we have a snapshot collision
			zfs destroy release/scratch@${BUILDID}
		fi
	fi
	rm /tmp/${BUILDID}.snap
}
