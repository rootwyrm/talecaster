#!/bin/sh

. /opt/talecaster/lib/talecaster.lib.sh

if [ -f /opt/talecaster/etc/auto.conf ]; then
	. /opt/talecaster/etc/auto.conf
else
	echo "$(date) [ERROR] System has not run TaleCaster autoconfig yet."
	exit 1
fi
if [ -f /opt/talecaster/etc/talecaster.conf ]; then
	. /opt/talecaster/etc/talecaster.conf
else
	echo "$(date) [ERROR] System has not run TaleCaster autoconfig yet."
	exit 1
fi

pdr_check_conf()
{
	if [ ! -f $PDR_CONF ]; then
		## Build from zero
		cp $TC_HOME/etc/poudriere/poudriere.conf $PDR_CONF
		if [ $? -ne 0 ]; then
			log_tc "Unable to copy in $PDR_CONF!" E
		fi
		pdr_build_conf
	elif [ -f $PDR_CONF ]; then
		grep ^ZPOOL=talecaster$ $PDR_CONF > /dev/null
		if [ $? -ne 0 ]; then
			log_tc "Invalid $PDR_CONF - rebuilding" w
			rm $PDR_CONF
			pdr_build_conf
		fi
	else
		## Things are fine.
		return 0
	fi
}

pdr_build_conf()
{
	## Let's make it right.
	if [ ! -f $PDR_CONF ]; then
		cp /opt/talecaster/etc/poudriere/poudriere.conf $PDR_CONF
	fi
	if [ -z $FREEBSD_SITE ]; then
	MIRROR_FREEBSD=download.freebsd.org
	MIRROR_TYPE=https
	export FREEBSD_SITE="$MIRROR_TYPE://$MIRROR_FREEBSD"
	fi
	sed -i -e 's,$MIRROR_FREEBSD,'$FREEBSD_SITE',' $PDR_CONF
	ram_in_mb=$(( $SYS_RAM / 1024 / 1024 ))
	half_ram_in_mb=$(( $ram_in_mb / 2 ))
	sed -i -e 's,$HALF_RAM_MB,'$half_ram_in_mb',' $PDR_CONF
	sed -i -e 's,$RAM_MB,'$ram_in_mb',' $PDR_CONF
	sed -i -e 's,$URL_HOST,'$my_hostname',' $PDR_CONF
	sed -i -e 's,$BUILD_HOST,poudriere.'$my_hostname',' $PDR_CONF
	sed -i -e 's,$SIGNING_KEY,'$PDR_KEY',' $PDR_CONF
}

pdr_bootstrap()
{
	## Check if our poudriere config is there
	## XXX: This logic is broken, needs fixed.
	#if [ -f /usr/local/etc/poudriere.conf ]; then
	#	grep ^ZPOOL=talecaster$ /usr/local/etc/poudriere.conf
	#	if [ $? != 0 ]; then
	#		tc_log "$PDR_CONF invalid trying to bootstrap!" E
	#		echo "[ERROR] $PDR_CONF invalid trying to bootstrap!"
	#		exit 1
	#	fi
	if [ -f /usr/local/etc/poudriere.conf ]; then
		## Create our initial ports tree.
		poudriere ports -c -m portsnap
		## Create our jail from our jails.
		#poudriere jail -c -j tcpdr -v $(freebsd-version | cut -d - -f 1,2) -a $(uname -m) -m url=file:///opt/talecaster/dist/$(freebsd-version | cut -d - -f 1,2)/
		#if [ $? -ne 0 ]; then
		#	echo "ERROR creating tcpdr jail"
		#	exit 1
		#fi
		## Kickstart our packages. Be noisy about it to verify function.
		poudriere bulk -ctr -j tcpdr -z talecaster ports-mgmt/pkg
		if [ $? -ne 0 ]; then
		   echo "ERROR kickstarting package set."
		   exit 1
	   fi
	fi
}

pdr_fix_zfs()
{
	## Modify the poudriere ZFS
	case $CPU_AESNI in
		true)
			export ZFS_DEDUP=sha512,verify
			;;
		false)
			export ZFS_DEDUP=sha256
			;;
	esac

	## XXX: We override certain ZFS options to prevent clash, except for 
	## the $ZFS_DEDUP value which is set based on AESNI.
	ZFS_OPTS="compression=lz4 dedup=$ZFS_DEDUP aclinherit=passthrough aclmode=passthrough"

	zfs list | grep talecaster/poudriere > /dev/null
	if [ $? -eq 1 ]; then
		echo "$(date) [ERROR] Filesystem does not exist."
		exit 1
	fi

	for x in `zfs list | grep talecaster/poudriere | awk '{print $1}'`; do
		zfs set $ZFS_OPTS $x
		if [ $? -ne 0 ]; then
			log_tc "Failed to set options on $x." E
		fi
	done
}

pdr_key_generate()
{
	## Generate our signing key
	if [ ! -d /opt/talecaster/etc/poudriere ]; then
		echo "$(date) [ERROR] /opt/talecaster/etc/poudriere does not exist!"
		exit 1
	elif [ -f $PDR_KEY ]; then
		echo "$(date) [NOTICE] $PDR_KEY already exists - not replacing."
		fingerprint=$(openssl pkcs8 -in $PDR_KEY -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c | awk '{print $2}')
		log_tc "$PDR_KEY fingerprint: $fingerprint" m
		return 0
	else	
		if [ -f /usr/local/sbin/openssl ]; then
			sslbin=/usr/local/sbin/openssl
		else
			sslbin=/usr/bin/openssl
		fi
		## Generate the key
		$sslbin genrsa -out $PDR_KEY 8192 > /dev/null 2>&1
		log_tc "Generated 8192 bit key $PDR_KEY" m
		$sslbin rsa -in ${PDR_KEY} -pubout -out ${PDR_PUB}
		fingerprint=$(openssl pkcs8 -in $PDR_KEY -inform PEM -outform DER -topk8 -nocrypt | openssl sha1 -c | awk '{print $2}')
		log_tc "$PDR_KEY fingerprint: $fingerprint" m
	fi
}

pdr_config_generate()
{
	## Our poudriere directory is a known quantity. 
	## NOTE: Always blow away any existing configuration.
	if [ -f $PDR_REPO ]; then
		rm -f $PDR_REPO
	fi
	## XXX: Work around weirdness in sh
	echo "talecaster.local {" > $PDR_REPO
	cat <<-EOF >> $PDR_REPO
		enabled: yes,
		url: "file:///opt/talecaster/poudriere/data/packages/$(freebsd-version | cut -d - -f 1,2)/tcpdr/",
		mirror_type: "srv",
		signature_type: "pubkey",
		pubkey: "/opt/talecaster/etc/poudriere/talecaster.pub"
	EOF
	echo '}' >> $PDR_REPO
	log_tc "Updated $PDR_REPO" m
}

pdr_check_conf
pdr_build_conf
pdr_key_generate
pdr_bootstrap
pdr_fix_zfs
pdr_config_generate
