#!/bin/sh

if [ -f /opt/talecaster/config/jail.conf ]; then
	. /opt/talecaster/config/jail.conf
fi

## Templating
if [ -z $FREEBSD_SITE ]; then
	MIRROR_FREEBSD=download.freebsd.org
	MIRROR_TYPE=https
	export FREEBSD_SITE="$MIRROR_TYPE://$MIRROR_FREEBSD"
fi

VERSION=$(freebsd-version |cut -d - -f 1,2)
ARCH=$(uname -m)

retrieve_base()
{
	# Grab packages to stash.
	mkdir /talecaster/downloads/_self
	LOCALSTORE=/talecaster/downloads/_self
	if [ ! -d $LOCALSTORE/$VERSION ]; then
		mkdir $LOCALSTORE/$VERSION
	fi
	for p in MANIFEST base.txz kernel.txz lib32.txz; do
		fetch -m $FREEBSD_SITE/ftp/releases/$ARCH/$VERSION/$p -o $LOCALSTORE/$VERSION/$p 
		if [ $? -ne 0 ]; then
			echo "Error retrieving $p"
		fi
	done

	## Validate packages.
	for a in `cat $LOCALSTORE/$VERSION/MANIFEST | awk '{print $1}'`; do
		local worksum=$(cat $LOCALHOST/$VERSION/MANIFEST | grep ^$a | awk '{print $2}')
		test -f $LOCALSTORE/$VERSION/$a
		if [ $? -eq 0 ]; then
			if [[ $(sha256 -q $LOCALSTORE/$VERSION/$a) -eq $worksum ]]; then
				## Checksum past.
				echo "$a: Checksum Validated."
			else
				echo "$a: Invalid checksum!"
				exit 1
			fi
		fi
	done
}

extract_base()
{
	local TPL_HOME=/opt/talecaster/jails/base
	for p in base.txz kernel.txz lib32.txz; do
		echo "Extracting $p..."
		tar -xf $LOCALSTORE/$VERSION/$p -C $TPL_HOME
	done
	
	## Update the template
	freebsd-update -b $TPL_HOME fetch install
	freebsd-update -b $TPL_HOME IDS
}

create_jailtpl()
{
	local TPL_HOME=/opt/talecaster/jails/tc_base

	## Create our directorkies
	mkdir -p $TPL_HOME/etc
	mkdir -p $TPL_HOME/tmp
	mkdir -p $TPL_HOME/var
	mkdir -p $TPL_HOME/usr/local
	mkdir -p $TPL_HOME/home
	cp /etc/resolv.conf $TPL_HOME/etc/resolv.conf
	cp /etc/localtime $TPL_HOME/etc/localtime
	cp /etc/krb5.conf $TPL_HOME/etc/krb5.conf
	mkdir -p $TPL_HOME/usr/local/etc/pkg/repos
	cp /usr/local/etc/pkg/repos/* $TPL_HOME/usr/local/etc/pkg/repos
}

link_base_and_template()
{
	local TPL_HOME=/opt/talecaster/jails/base
	local TCAPP=$TPL_HOME/tcapp
	mkdir $TCAPP
	ln -s $TCAPP/etc $TPL_HOME/etc
	ln -s $TCAPP/tmp $TPL_HOME/tmp
	ln -s $TCAPP/var $TPL_HOME/var
	ln -s $TCAPP/usr/local $TPL_HOME/usr/local
	ln -s $TCAPP/home $TPL_HOME/home
}

deploy_packages()
{
	local TCAPP=/opt/talecaster/jails/base/tcapp
	pkg -c $TCAPP -y install python27 perl5.24
}
