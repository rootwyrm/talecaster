#!/bin/sh
#
# $TaleCaster: master/talecaster/bin/jail_init.sh
#
# Copyright (C) 2017-* Phillip R. Jaenke
# All rights reserved
#
# SEE /opt/talecaster/LICENSE for license details.

. /opt/talecaster/lib/talecaster.lib.sh

load_tc_autoconf		# /opt/talecaster/etc/auto.conf
load_tc_jailconf		# /opt/talecaster/etc/tcjail.conf

## NOTE: use mirror mode (-m) to reduce bandwidth for everyone involved
## XXX: fetch can use $HTTP_USER_AGENT but NYI on our side.
export version=$(freebsd-version | cut -d - -f 1,2)
export arch=$(uname -m)
export fetch_arg="-q -m --user-agent=TaleCaster_FreeBSD_"$version""

base_fetch()
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
		# XXX: This runs as root.
		mkdir -p $MIRROR_STORAGE/$version
	fi
	# Files we need.
	export BASE="MANIFEST base.txz lib32.txz"
	for txz in $BASE; do
		fetch $fetch_arg $FREEBSD_SITE/ftp/releases/$arch/$version/$txz \
			-o $MIRROR_STORAGE/$version/$txz
		if [ $? -ne 0 ]; then
			log_tc "Unable to retrieve $txz" E
		fi
	done
}

base_validate()
{
	## Validate that we downloaded good tarballs.
	for f in `cat $MIRROR_STORAGE/$version/MANIFEST | awk '{print $1}'`; do
		test -f $MIRROR_STORAGE/$version/$f > /dev/null
		if [ $? -eq 0 ]; then
			local worksum=$(cat $MIRROR_STORAGE/$version/MANIFEST | grep ^$f | \
					awk '{print $2}')
			if [ $(sha256 -q $MIRROR_STORAGE/$version/$f) = $worksum ]; then
				## Checksum passed.
				log_tc "$MIRROR_STORAGE/$version/$f: Checksum Validated" m
			else
				## Checksum failed.
				log_tc "$MIRROR_STORAGE/$version/$f: Checksum Failure!" E
			fi
		else
			log_tc "$MIRROR_STORAGE/$version/$f: no file to validate" m
		fi
	done
}

base_install()
{
	jail0_path=$(zfs list | grep talecaster/jail/jail0 | awk '{print $5}')
	if [ -z $jail0_path ]; then
		log_tc "Could not find jail0!" E
	fi

	for b in "base.txz lib32.txz"; do
		tar -xvf $MIRROR_STORAGE/$version/$f/$b -C $jail0_path/
		CHECK_ERROR base_install_untar $?
	done

	# Now we update to the latest.
	env UNAME_r=$version /usr/sbin/freebsd-update -b $jail0_path fetch install
	CHECK_ERROR base_install_update $?

	## Now IDS it.
	env UNAME_r=$version /usr/sbin/freebsd-update -b $jail0_path IDS
	CHECK_ERROR base_install_ids $?

	## XXX: Do not copy the resolv.conf because that's unique per-jail!
	# Install localtime
	cp /etc/localtime $jail0_path/etc/localtime
	## XXX: jail0 always gets a static IP and hostname based on the host.
	echo hostname\"jail0.$(hostname)\" > $jail0_path/etc/rc.conf
	echo '# jail0 static address' >> $jail0_path/etc/rc.conf
	echo 'ifconfig_epair0b_inet=\"172.17.0.240 netmask 255.255.255.0\"' >> \
		$jail0_path/etc/rc.conf
}

jail_zfs_create_jail0()
{
	## XXX: Needs interruptor here for destructive upgrade
	## XXX: Temp Hack
	. /opt/talecaster/etc/auto.conf
	case $CPU_AESNI in
		true)
			export ZFS_DEDUP=sha512,verify
			;;
		false)
			export ZFS_DEDUP=sha256
			;;
	esac

	## XXX: We override whatever the user wants for ZFS options to prevent
	## clash, except for the $ZFS_DEDUP value which is set based on AESNI. 
	local ZFS_OPTS="-o compression=lz4 -o dedup=$ZFS_DEDUP -o normalization=formD -o \
		aclinherit=passthrough -o aclmode=passthrough" 

	## Check if we have our jail filesystem first. We might not.
	zfs list | grep talecaster/jail > /dev/null
	if [ $? -eq 1 ]; then
		## We don't.
		zfs create $ZFS_OPTS talecaster/jail
	fi

	zfs create $ZFS_OPTS talecaster/jail/jail0
	if [ $? -ne 0 ]; then
		log_tc "Failed to create jail0!" E
	fi
	
	jail0_path=$(zfs list | grep talecaster/jail/jail0 | awk '{print $5}')
	if [ -z $jail0_path ]; then
		log_tc "Could not find jail0!" E
	fi
}

base_fetch
base_validate
jail_zfs_create_jail0

#c:inkpot
