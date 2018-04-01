#!/bin/sh
#
# Copyright 2017-* TaleCaster and Contributors
# All rights reserved
#
# LICENSE PLACEHOLDER - DO NOT COPY OR REDISTRIBUTE
#
#
# This is the script which actually builds a TaleCaster release, usually done on
# cliffwalker.rootwyrm.pvt. Releases are pkgbase and signed by one of two valid keys.
# 
# cliffwalker.rootwyrm.pvt: SHA256:LzwdHaBytMsG+3AJcqAwp4Gi/e21jVo/7JpZaHpxhBg
# stormcaller.rootwyrm.pvt: NYI

# Ensure our directories are setup correctly.

## IMPORTANT VARIABLES:
# WORLDDIR=/usr/src		from release.sh
# eval chroot ${CHROOTDIR} make -C /usr/src \


directory_setup()
{
	if [ ! -d /release/scratch ]; then
		zfs create release/scratch
		if [ $? -ne 0 ]; then
			echo "Failed to setup /release/scratch"
			exit 1
		fi
	else
		zfs destroy release/scratch
		zfs create release/scratch
	fi
	if [ ! -d /release/talecaster ]; then
		zfs create release/talecaster
		if [ $? -ne 0 ]; then
			echo "Failed to setup /release/talecaster"
			exit 1
		fi
	fi
}

retrieve_source()
{
	if [ -z $RELEASE ]; then
		RELEASE=$(uname -r | cut -d - -f 1)
	fi
	if [ -z $SVNSITE ]; then
		SVNSITE=svn://svn.reebsd.org/base/
	fi
	if [ -d /release/src/releng/$RELEASE ]; then
		svnlite update /release/src/releng/$RELEASE
		if [ $? -ne 0 ]; then
			echo "Error updating /release/src/releng/$RELEASE"
			exit 1
		fi
	else
		svnlite co $SVNSITE/releng/$RELEASE /release/src/releng/$RELEASE
		if [ $? -ne 0 ]; then
			echo "Error checking out /release/src/releng/$RELEASE"
			exit 1
		fi
	fi
}

release_key_setup()
{
	if [ ${EUID} != "0" ]; then
		## We're not root.
		sudo cp /etc/ssl/release/$(hostname -s).release.key ${HOME}/$(hostname -s).release.key
		if [ $? -ne 0 ]; then
			echo "Error using sudo to copy release key."
			exit 1
		fi
		chmod 0600 ${HOME}/$(hostname -s).release.key
		expectfp=`grep $(hostname) $0 | awk '{print $3}'`
		if [ $(ssh-keygen -lf ${HOME}/$(hostname -s).release.key | awk '{print $2}') != ${expectfp} ]; then
			echo "Fatal signing key mismatch."
			exit 1
		fi
	else
		## We are building as root.
		expectfp=`grep $(hostname) $0 | awk '{print $3}'`
		if [ $(ssh-keygen -lf /etc/ssl/release/$(hostname -s).release.key | awk '{print $2}') != ${expectfp} ]; then
			echo "Fatal signing key mismatch."
			exit 1
		 fi
	fi
}

configuration_read()
{
	if [ ! -f /release/talecaster/release.conf ]; then
		echo "No release configuration. Refusing to build."
		exit 1
	fi
	. /release/talecaster/release.conf

	## Now iterate for our mandatory variables
	for v in WORLDDIR CHROOTDIR OBJDIR DESTDIR KERNEL; do
		if [ -z $v ]; then
			echo "$v unset in configuration."
			exit 1
		fi
	done

	## XXX: Such a giant fucking hack.
	MAKEOBJDIRPREFIX=$OBJDIR
	
	if [ ! -z ${LOCAL_DIRS} ]; then
		echo "LOCAL_DIRS = ${LOCAL_DIRS}"
	fi
	if [ ! -z ${LOCAL_MTREE} ]; then
		if [ ! -z ${TALECASTER_OVERLAY} ]; then
			LOCAL_MTREE=${TALECASTER_OVERLAY}
		fi
	fi

	if [ ! -z ${PORTS_MODULES} ]; then
		echo "PORTS_MODULES = ${PORTS_MODULES}"
	fi
	
	if [ ! -z ${JFLAG} ]; then
		echo "JFLAG = ${JFLAG}"
	fi

	## If we're crossbuilding, note that.
	if [ ! -z ${TARGET} ] || [ ! -z ${TARGET_ARCH} ]; then
		echo "CROSSBUILDING: ${TARGET} ${TARGET_ARCH}"
	fi
}

