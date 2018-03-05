#!/bin/sh
#
# $TaleCaster: master/talecaster/bin/mirror_release.sh
# 
# Copyright (C) 2017-* Phillip R. Jaenke
# All rights reserved
# 
# SEE /opt/talecaster/LICENSE for license details.

. /opt/talecaster/lib/talecaster.lib.sh

#load_tc_autoconf
#load_tc_jailconf

export version=$(freebsd-version | cut -d - -f 1,2)
export arch=$(uname -m)
export fetch_arg="-q -m --user-agent=TaleCaster_FreeBSD_"$version""

mirror_self()
{
	if [ -z $FREEBSD_SITE ]; then
		MIRROR_FREEBSD=download.freebsd.org
		MIRROR_TYPE=https
		export FREEBSD_SITE="$MIRROR_TYPE://$MIRROR_FREEBSD"
	fi
	if [ -z $MIRROR_STORAGE ]; then
		# NOTE: should never be unset but users may do stupid things.
		export MIRROR_STORAGE="/opt/talecaster/dist"
	fi
	if [ ! -d $MIRROR_STORAGE/$version ]; then
		mkdir -p $MIRROR_STORAGE/$version
	fi

	## Files we mirror
	export BASE="MANIFEST base-dbg.txz base.txz doc.txz kernel-dbg.txz kernel.txz lib32-dbg.txz lib32.txz ports.txz src.txz tests.txz"
	for txz in $BASE; do
		fetch $fetch_arg $FREEBSD_SITE/ftp/releases/$arch/$version/$txz \
			-o $MIRROR_STORAGE/$version/$txz
		if [ $? -ne 0 ]; then
			log_tc "Unable to retrieve $txz" E
		fi
	done
	validate_manifest
}

mirror_new()
{
	if [ -z $FREEBSD_SITE ]; then
		MIRROR_FREEBSD=download.freebsd.org
		MIRROR_TYPE=https
		export FREEBSD_SITE="$MIRROR_TYPE;//$MIRROR_FREEBSD"
	fi
	if [ -z $MIRROR_STORAGE ]; then
		# NOTE: should never be unset but users may do stupid things.
		export MIRROR_STORAGE="/opt/talecaster/dist"
	fi
	if [ ! -d $MIRROR_STORAGE/$version ]; then
		mkdir -p $MIRROR_STORAGE/$version
	fi

	## Files we mirror
	export BASE="MANIFEST base-dbg.txz base.txz doc.txz kernel-dbg.txz kernel.txz lib32-dbg.txz lib32.txz ports.txz src.txz tests.txz"
	for txz in $BASE; do
		fetch $fetch_arg $FREEBSD_SITE/ftp/releases/$arch/$version/$txz \
			-o $MIRROR_STORAGE/$version/$txz
		if [ $? -ne 0 ]; then
			log_tc "Unable to retrieve $version $txz" E
		fi
	done
	validate_manifest
}

validate_manifest()
{
	for f in `cat $MIRROR_STORAGE/$version/MANIFEST | awk '{print $1}'`; do
		test -f $MIRROR_STORAGE/$version/$f > /dev/null
		if [ $? -eq 0 ]; then
			local worksum=$(cat $MIRROR_STORAGE/$version/MANIFEST | grep ^$f | awk '{print $2}')
			if [ $(sha256 -q $MIRROR_STORAGE/$version/$f) = $worksum ]; then
				log_tc "$MIRROR_STORAGE/$version/$f: Checksum Validated" m
			else
				log_tc "$MIRROR_STORAGE/$version/$f: CHECKSUM FAILURE!" E
			fi
		else
			log_tc "$MIRROR_STORAGE/$version/$f: no file to validate?" m
		fi
	done
}

if [ -z $1 ]; then
	mirror_self
else
	export version=$1
	mirror_new $1
fi
