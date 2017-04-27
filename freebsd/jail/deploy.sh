#!/bin/sh
#

JAIL_BASE=/opt/talecaster/jails/base

## Quick and dirty...
for j in transmission nzbget sickrage couchpotato headphones; do
	mkdir /opt/talecaster/jails/$j
	cp -pR $JAIL_BASE/* /opt/talecaster/jails/$j/
done
