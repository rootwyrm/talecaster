#!/bin/sh
#
# $TaleCaster: master/talecaster/bin/tc_autoconf.sh
#
# Copyright (C) 2017-* Phillip R. Jaenke
# All rights reserved
# 
# SEE /opt/talecaster/LICENSE for license details.
# PLACEHOLDER

#. /opt/talecaster/lib/talecaster.lib.sh

CONFFILE="/opt/talecaster/etc/auto.conf"

## Zero out the file every run.
cat /dev/null > $CONFFILE

## Identify when the last run was.
echo -n "# Last Run: " >> $CONFFILE
date >> $CONFFILE

## Generate a dmesg file to work from
DMESG=/tmp/tc_auto_dmesg
dmesg > $DMESG

## Determine our CPU
echo '# '$(grep ^CPU: $DMESG)'' >> $CONFFILE

## Get our memory in bytes
REAL_RAM=$(grep ^real $DMESG | awk '{print $4}')
echo "SYS_RAM=$REAL_RAM" >> $CONFFILE
## Set our memory tuning based on typical values.
if [ $REAL_RAM -gt 34359738367 ]; then
	## 32GB+
	echo "SYS_RAM_PROFILE=bigmem" >> $CONFFILE
elif [ $REAL_RAM -gt 17179869183 ]; then
	## 16-32GB
	echo "SYS_RAM_PROFILE=highmem" >> $CONFFILE
elif [ $REAL_RAM -gt 8589934591 ]; then
	## 8-16GB
	echo "SYS_RAM_PROFILE=normal" >> $CONFFILE
elif [ $REAL_RAM -gt 4294967295 ]; then
	## 4-8GB
	echo "SYS_RAM_PROFILE=lowmem" >> $CONFFILE
else
	## Below minimums
	echo "$0: system memory is $REAL_RAM and below minimums, refusing to continue."
	touch /opt/talecaster/etc/disable
	exit 1
fi

## Check if we're virtual.
grep ^Hypervisor: $DMESG
if [ $? -eq 0 ]; then
	echo 'SYS_VIRTUAL=true' >> $CONFFILE
	## If we are, get our hypervisor
	SYS_HYPERVISOR=$(grep ^Hypervisor: $DMESG | awk -F " " '{print $NF}')
	echo 'SYS_VIRTUAL_HV='$SYS_HYPERVISOR'' >> $CONFFILE
else
	echo 'SYS_VIRTUAL=false' >> $CONFFILE
fi

## AESNI check
grep AESNI $DMESG 
if [ $? -eq 0 ]; then
	echo 'CPU_AESNI=true' >> $CONFFILE
else
	echo 'CPU_AESNI=false' >> $CONFFILE
fi
## SSE2 check
grep SSE2 $DMESG
if [ $? -eq 0 ]; then
	echo 'CPU_SSE2=true' >> $CONFFILE
else
	echo 'CPU_SSE2=false' >> $CONFFILE
fi
## AVX check
grep AVX $DMESG
if [ $? -eq 0 ]; then
	echo 'CPU_AVX=true' >> $CONFFILE
else
	echo 'CPU_AVX=false' >> $CONFFILE
fi

######################################################################
## Networking
######################################################################
## Identify our network drivers.
## ETHERNET
## Blacklisted: aue(4) axe(4) axge(4) cdce(4) cue(4) fe(4) kue(4) my(4) nfe(4) re(4) rl(4) rue(4) udav(4) 
for int in ae age ale bce bfe bge bnxt cas cs em et igb jme lge msk nge stge ti vge; do
	grep ^$int[0-9] $DMESG > /dev/null 
	if [ $? -eq 0 ]; then
		echo -n "$int " >> /tmp/tc_auto_gbe
	fi
done
if [ $(wc /tmp/tc_auto_gbe | awk '{print $2}') -gt 0 ]; then
	# We have working adapters.
	echo -n 'NET_GBE="'$(cat /tmp/tc_auto_gbe)'"' >> $CONFFILE
fi
rm /tmp/tc_auto_gbe

## 10GbE
for int in cxgb cxgbe ixgb ixgbe ixl mlx4en mxl5en mxge nxge oce qlnxe qlxgb \
qlxgbe qlxge sfxge vxge ; do
	grep ^$int[0-9] $DMESG > /dev/null
	if [ $? -eq 0 ]; then
		echo -n "$int " >> /tmp/tc_auto_tge
	fi
done

## Check if there are any 10GbE adapters found
if [ -f /tmp/tc_auto_tge ] && [ $(wc -l /tmp/tc_auto_tge | awk '{print $2}') -gt 0 ]; then
	for int in cxgb cxgbe ixgb ixgbe ixl mlx4en mxl5en mxge nxge oce qlnxe qlxgb \
		qlxgbe qlxge sfxge vxge ; do
		grep $int /tmp/tc/auto_tge > /dev/null
		if [ $? -eq 0 ]; then
			echo "NET_10GBE=true" >> $CONFFILE
			break;
		fi
	done
fi
grep NET_10GBE=true $CONFFILE > /dev/null
if [ $? -eq 0 ]; then
	# We have working 10GbE adapters.
	echo -n 'NET_TENG="'$(cat /tmp/tc_auto_tge)'"' >> $CONFFILE
	rm /tmp/tc_auto_tge
fi
