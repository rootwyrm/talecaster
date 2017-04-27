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

# Grab packages to stash.
mkdir /talecaster/downloads/_self
LOCALSTORE=/talecaster/downloads/_self
mkdir $LOCALSTORE/$VERSION
for p in base.txz kernel.txz lib32.txz; do
	fetch -m $FREEBSD_SITE/ftp/releases/$ARCH/$VERSION/$p -o $LOCALSTORE/$VERSION/$p 
	if [ $? -ne 0 ]; then
		echo "Error retrieving $p"
	fi
done

TPL_HOME=/opt/talecaster/jails/base
for p in base.txz kernel.txz lib32.txz; do
	tar -xf $LOCALSTORE/$VERSION/$p -C $TPL_HOME
done

cp /etc/resolv.conf $TPL_HOME/etc/resolv.conf
cp /etc/localtime $TPL_HOME/etc/localtime
cp /etc/krb5.conf $TPL_HOME/etc/krb5.conf
mkdir -p $TPL_HOME/usr/local/etc/pkg/repos
cp /usr/local/etc/pkg/repos/* $TPL_HOME/usr/local/etc/pkg/repos

## Update the template
freebsd-update -b $TPL_HOME fetch install
freebsd-update -b $TPL_HOME IDS

## Deploy standard packages
## TODO
