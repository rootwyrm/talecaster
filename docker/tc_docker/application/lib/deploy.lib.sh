#!/bin/bash
# application/lib/deploy.lib.sh

# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# COMMERCIAL REDISTRIBUTION IN ANY FORM IS PROHIBITED WITHOUT EXPRESS
# WRITTEN CONSENT OF THE AUTHOR(S). 

## NOTE: Use export due to bash limitations
export chkfile="/firstboot"
export basedir="/opt/talecaster/defaults"
export svcdir="/etc/service"

CHECK_ERROR()
{
	if [ $1 -ne 0 ]; then
		RC=$1
		if [ -z $2 ]; then
			echo "[FATAL] Error occurred in unknown location"
			exit $RC
		else
			echo "[FATAL] Error occurred in $2 : $1"
			exit $RC
		fi
	fi
}

## Trap early
test_deploy()
{
	if [ ! -f $chkfile ]; then
		exit 0
	else
		# Ingest configuration
		if [ -f $chkfile ]; then
			. $chkfile
		elif [ -f "$chkfile".conf ]; then
			. "$chkfile".conf
		fi
	fi
}

ingest_environment()
{
	if [ -s /.dockerenv ]; then
		. /.dockerenv
	fi
	if [ -s /.dockerinit ]; then
		. /.dockerinit
	fi
}

deploy_complete()
{
	if [ -f $chkfile ]; then
		rm $chkfile
	fi
	if [ -f /deploy.new ]; then
		rm /deploy.new
	fi

	# Be certain to not rerun firstboot.
	rm /etc/service/firstboot
}

######################################################################
## User Management
######################################################################
deploy_talecaster_user()
{
	## If on Synology, *always* run as admin:user to avoid issues
	if [[ -f /proc/syno_cpu_arch ]]; then
		export tcuser="media"
		export tcuid="1024"
		export tcgroup="users"
		export tcgid="100"
	else
		## Defaults are based on original infrastructure
		## media(60000):media(60000)
		## NOTE: Must be below 65534 due to client limits!!
		if [[ -z $tcuser ]]; then export tcuser="media"; fi
		if [[ -z $tcuid ]]; then export tcuid="60000"; fi
		if [[ -z $tcgroup ]]; then export tcgroup="media"; fi
		if [[ -z $tcgid ]]; then 
			grep $tcgroup /etc/group > /dev/null
			if [ $? -ne 0 ]; then
				export tcgid="60000"
				addgroup -g $tcgid $tcgroup
				CHECK_ERROR $? addgroup
			else
				grep $tcgroup /etc/group | cut -d : -f 3 > /tmp/gid
				export tcgid=$(cat /tmp/gid)
			fi
		fi
		echo "[DEPLOY] Set TaleCaster user $tcuser[$tcuid]:$tcgroup[$tcgid]"
		if [ -z $tcshell ]; then
			## XXX gliderlabs/docker-alpine/issues/141
			export tcshell=/bin/sh
		fi

		grep $tcuser /etc/passwd > /dev/null
		if [ $? -eq 0 ]; then
			if [[ $(id -u $tcuser) -eq $tcuid ]]; then
				echo "[DEPLOY] Found existing user $tcuser[$tcuid], keeping it."
			elif [[ $(id -u $tcuser) != 0 ]]; then
				## NOP User doesn't exist.
				echo -n "" > /dev/null
			else
				echo "[DEPLOY] Replacing user $tcuser[$(id -u $tcuser)]"
				deluser $tcuser
			fi
		fi
	fi

	## NOTE: Do not use backtick; known defect in handling.
	adduser -h /home/$tcuser -g "TaleCaster User" -u $tcuid -G $tcgroup -D -s $tcshell $tcuser
	CHECK_ERROR $? adduser

	## Clean up after ourselves
	if [ -f /tmp/gid ]; then
		rm /tmp/gid
	fi
}

deploy_tcuser_ownership()
{
	## XXX: use numeric to work around Synology issues that are not fixed
	## in DSM6.0 but are in DSM6.1. 
	if [[ -z $tcuid ]] || [[ -z $tcgid ]]; then
		printf '[FATAL] $tcuid or $tcgid unset!\n'
		return 1
	fi

	chown -R $tcuid:$tcgid /home/$tcuser
	CHECK_ERROR $? chown_home
	chmod 0700 /home/$tcuser
	chown -R $tcuid:$tcgid /config
	CHECK_ERROR $? chown_config

	if [ ! -d $app_destdir ] ; then
		chown -R $tcuid:$tcgid $app_destdir
		if [ $? -ne 0 ]; then
			echo "[FATAL] Could not adjust $app_destdir ownership."
			exit 1
		fi
		## Don't forget git if present
		chown -R $tcuid:$tcgid $app_destdir/.[a-zA-Z]*
		if [ $? -ne 0 ]; then
			echo "[FATAL] Could not adjust $app_destdir ownership."
			exit 1
		fi
	fi
}

######################################################################
## MOTD and Version Information
######################################################################
generate_motd()
{
	baserel="R0V0U0.0000"
	releasefile="/opt/talecaster/id.release"
	if [ -s $releasefile ]; then
		releaseid="UNTAGGED_DEVELOPMENT"
	else
		releaseid=$(cat $releasefile)
	fi

	cp /opt/talecaster/defaults/motd /etc/motd
	sed -i -e 's,BASERELID,'$baserel',' /etc/motd
	sed -i -e 's,RELEASEID,'$releaseid',' /etc/motd
	sed -i -e 's,APPNAME,'$app_name',' /etc/motd
	sed -i -e 's,APPURL,'$app_url',' /etc/motd

	if [ -f /opt/talecaster/app.message ]; then
		sed -i -e '/APPMESSAGE$/d' /etc/motd
		cat /opt/talecaster/app.message >> /etc/motd
	else
		sed -i -e '/APPMESSAGE$/d' /etc/motd
	fi
}

## NYI
##update_motd()

######################################################################
## Generic Application Functions
######################################################################
deploy_application_git()
{
	case $1 in
		[Rr][Ee][Ii][Nn][Ss][Tt]*)
		## Doesn't come up often, but might.
			if [[ -z $app_destdir ]] && [[ -d $app_destdir ]]; then
				rm -rf $app_destdir
				mkdir $app_destdir
			fi
			if [ -z $branch ]; then
				git clone $app_git_url -b master --depth=1 $app_destdir
			else
				git clone $app_git_url -b $branch --depth=1 $app_destdir
			fi
			CHECK_ERROR $? git_clone
			chown -R $tcuid:$tcgid $app_destdir
			return $?
			;;
		[Uu][Pp][Dd][Aa][Tt][Ee]*)
			if [ ! -d $app_destdir ]; then
				## Presume user error.
				deploy_application_git REINST
			else
				export return=$PWD; cd $app_destdir
				su $tcuser -c 'git pull'
				if [ $? -ne 0 ]; then
					echo "[WARNING] Error in git_pull_update!"
					exit 1
				fi
				cd $return
				unset return
			fi
			return $?
			;;
		*)
			echo "[FATAL] deploy_application_git() called with invalid argument."
			return 1
			;;
	esac
}

## NYI: update_application_git

######################################################################
## OpenSSL functions
## XXX: to be moved to talecaster/lib/openssl.lib.sh
######################################################################
ssl_ssc_create()
{
	export ssldir="/config/ssl"
	if [[ -f $ssldir/"$app_name".crt ]] || [[ -f $ssldir/"$app_name".crt ]]; then
		## Don't obliterate user keys
		echo "[SSL] Found existing $ssldir/"$app_name".crt, leaving in place."
		ssl_certificate_print
		return 0
	fi

	export sslpass=$(head -c 500 /dev/urandom | tr -dc a-zA-Z0-9 | head -c 64)
	export mydomain=$(cat /etc/resolv.conf | grep search | awk '{print $2}')
	if [ -z $shorthost ]; then
		export shorthost=$(cat /etc/hostname)
	fi
	## SSCs use docker container ID and domain
	export OPENSSLCONFIG=/opt/talecaster/defaults/openssl.cnf
	## Fix up openssl.cnf
	sed -i -e 's,_REPLACE_HOSTNAME_,'$shorthost'.'$mydomain',' $OPENSSLCONFIG
	sed -i -e 's,_DOMAIN_,'$mydomain',' $OPENSSLCONFIG

	## Generate the key
	openssl genrsa -des3 -out $ssldir/$app_name.key -passout env:sslpass 2048
	CHECK_ERROR $? ssl_gen_key

	## Gen CSR
	openssl req -new -x509 -days 3650 -batch -nodes \
		-config $OPENSSLCONFIG -key $ssldir/"$app_name".key \
		-out $ssldir/"$app_name".crt -passin env:sslpass
	CHECK_ERROR $? ssl_gen_csr

	mv $ssldir/"$app_name".key $ssldir/"$app_name".key.lock
	echo $sslpass > $ssldir/"$app_name".key.lock.string
	chmod 0400 $ssldir/"$app_name".key.lock.string

	## Unlock the key
	openssl rsa -in $ssldir/"$app_name".key.lock -out $ssldir/"$app_name".key -passin env:sslpass
	CHECK_ERROR $? ssl_unlock_key

	for sslfile in `ls $ssldir/"$app_name"*`; do
		chown $tcuid:$tcgid $sslfile
		chmod 0600 $sslfile
	done

	## Secure the key string.
	chown 0:0 $ssldir/"$app_name".key.lock.string
}

ssl_certificate_print()
{
	## Print the certificate info
	if [ -f $ssldir/"$app_name".crt ]; then
		crtfp=`openssl x509 -subject -dates -fingerprint -in $ssldir/"$app_name".crt | grep Finger`
		crtdns=`openssl x509 -text -noout -subject -in $ssldir/"$app_name".crt | grep DNS | awk '{print $1,$2,$3,$4,$5,$6}'`
		crtissuer=`openssl x509 -text -noout -subject -in $ssldir/"$app_name".crt | grep Issuer:`

		## Print information
		echo "[SSL] Certificate Issuer: $crtissuer"
		CHECK_ERROR $? ssl_print_issuer
		echo "[SSL] Certificate Hostnames: $crtdns"
		CHECK_ERROR $? ssl_print_hostname
		echo "[SSL] Certificate Fingerprint: $certfp"
		CHECK_ERROR $? ssl_print_fingerprint
	elif [ ! -z $NOSSL ]; then
		echo "[APPLICATION] Ignoring SSL - no application support."
	else
		echo "[WARNING] Could not find SSL certificate!"
		exit 1
	fi
}

ssl_ownership_fixup()
{
	if [[ $(stat -c %U $ssldir/"$app_name".crt) != $tcuser ]]; then
		chown $tcuser $ssldir/"$app_name".crt
	fi
	if [[ $(stat -c %G $ssldir/"$app_name".crt) != $tcgroup ]]; then
		chgrp $tcgroup $ssldir/"$app_name".crt
	fi
	if [[ $(stat -c %a $ssldir/"$app_name".crt) != '700' ]]; then
		chmod 0700 $ssldir/"$app_name".crt
	fi
}

######################################################################
## runit functions
######################################################################
runit_linksv()
{
	if [ -z $1 ] && [ -z $app_svname ]; then
		echo "[FATAL] runit_linksv() called with no arguments."
	elif [ -d /etc/sv/$app_svname ]; then
		ln -s /etc/sv/$app_svname /etc/service
		if [ $? -ne 0 ]; then
			echo "[FATAL] Failed to install $app_svname in runit."
			exit 1
		fi
	elif [ -d /etc/sv/$1 ]; then
		ln -s /etc/sv/$1 /etc/service
		if [ $? -ne 0 ]; then
			echo "[FATAL] Failed to install $1 in runit."
			exit 1
		fi
	fi
}
