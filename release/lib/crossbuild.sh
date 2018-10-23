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
# qemu functions
######################################################################

setup_qemu()
{
	if [ -z $1 ]; then
		log_error "setup_qemu called without architecture." 10
	fi
	## is qemu even installed?
	pkg info qemu-user-static > /dev/null
	if [ $? -ne 0 ]; then
		log_error "qemu-user-static not installed." 20
	fi
	## check if we have the right qemu binary available
	if [ ! -f /usr/local/bin/qemu-${ARCH}-static ]; then
		log_error "qemu-${ARCH}-static missing from the system." 20
	fi
	## now let's see if binmiscctl has the architecture.
	if [[ $(/usr/sbin/binmiscctl lookup ${ARCH}) != 0 ]]; then
		log_error "architecture ${arch} not enabled in binmiscctl." 20
	fi
}

setup_arch_buildworld()
{
	if [ -z $1 ]; then
		log_error "setup_arch_args called without architecture." 10
	fi

	## actually set up our args
	TARGET_ARCH=${ARCH}

	echo "make TARGET_ARCH=${ARCH} SRCCONF=${SRCCONF} __MAKE_CONF=${MAKECONF} -j 1 buildworld" > ${SCRATCH}/${BUILDID}/buildworld.sh
	echo "make TARGET_ARCH=${ARCH} SRCCONF=${SRCCONF} __MAKE_CONF=${MAKECONF} KERNCONF=${KERNCONF} -j 1 buildkernel" > ${SCRATCH}/${BUILDID}/buildkernel.sh
	echo "make TARGET_ARCH=${ARCH} SRCCONF=${SRCCONF} __MAKE_CONF=${MAKECONF} KERNCONF=${KERNCONF} DESTDIR=/release/scratch/${BUILDID}/_mount.freebsd installkernel" > ${SCRATCH}/${BUILDID}/installkernel.sh
}
