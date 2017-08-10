#!/bin/sh

if [ ! -f /opt/talecaster/etc/disk.conf ]; then
	echo "Empty disk configuration! Refusing to continue."
	echo "Set /opt/talecaster/etc/disk.conf before running."
	exit 255
fi

disk_init() {
	for d in `cat /opt/talecaster/etc/disk.conf | grep -v ^cache`; do
		## Check if disk exists
		test -f /dev/$d
		if [ $? -ne 0 ]; then
			echo "ERROR: disk $d not attached!"
			exit 1
		fi
	done
	echo "**********************************************************************"
	echo "WARNING! Selecting yes here will ERASE the contents of these disks!"
	## XXX: check and print only if a talecaster pool exists?
	echo "It will also IRRETRIEVABLY DELETE any existing talecaster pool!"
	cat `/opt/talecaster/etc/disk.conf`
	echo "**********************************************************************"
	## XXX: Prompt for y/no
	while true; do
		read -p "Continue?" yn
		case $yn in
			[Yy]*) echo "Erasing disks."; break;;
			[Nn]*) exit 0;;
			*) echo "Entry not understood. Answer y or n.";;
		esac
	done
	## XXX: check and delete existing talecaster zpool

	zpool create -f -O aclmode=passthrough -O aclinherit=passthrough \
		-o autoexpand=on -o failmode=continue talecaster \
		`cat /opt/talecaster/etc/disk.conf | grep -v ^cache`
}

zfs_tune_root() {
	## XXX: Placeholder for NFS

	## Always set dedup; use sha512 for AESNI, sha256 for the rest
	dmesg | grep -i aesni > /dev/null
	if [ $? -eq 0 ]; then
		kldstat | grep aesni > /dev/null
		if [ $? -ne 0 ]; then
			echo "## Enable AESNI" >> /boot/loader.conf
			echo "crypto_load=YES" >> /boot/loader.conf
			echo "cryptodev_load=YES" >> /boot/loader.conf
			echo "aesni_load=YES" >> /boot/loader.conf
		fi
		export DEDUP=sha512
	else
		export DEDUP=sha256
	fi
	zfs set -o dedup=$DEDUP talecaster
	zfs set -o volmode=geom talecaster
	## Cycle the pool to force volmode geom
	zpool export talecaster
	zpool import talecaster
	
	## Set our goodies on the root filesystem
	zfs set -o dedup=$DEDUP zroot
	zfs set -o compression=lz4 zroot
	zfs set -o volmode=geom zroot
	## XXX: vscan not supported on FreeBSD
	## XXX: xattr not supported on FreeBSD
}

zfs_cache_talecaster() {
	## Add cache disks to talecaster.
	grep ^cache /opt/talecaster/etc/disk.conf > /dev/null
	if [ $? -eq 0 ]; then
		## User has cache disks to use
		for c in `grep ^cache /opt/talecaster/etc/disk.conf`; do
			zpool add talecaster $c
		done
	fi
}

zfs_zvol_talecaster() {
	## Set up our base jail zfs.
	zfs create -o compression=lz4 talecaster/jail/base
	## XXX: need formD to avoid OS incompatibilities.
	datavolopt="-o normalization=formD -o devices=off -o aclinherit=passthrough -o aclmode=inherit"
	zfs create $datavolopt talecaster/television
	zfs create $datavolopt talecaster/movies
	zfs create $datavolopt talecaster/music
	zfs create $datavolopt talecaster/books
	zfs create $datavolopt talecaster/comics

	## XXX: implement the application selection in menu system
}

## NYI: zfs_cache_build() 
## NYI: zfs_cache_poudriere()

disk_init
zfs_tune_root
zfs_cache_talecaster
zfs_zvol_talecaster
