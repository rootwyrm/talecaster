#!/bin/sh
#
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
#
# NO COMMERCIAL REDISTRIBUTION IN ANY FORM IS PERMITTED WITHOUT
# EXPRESS WRITTEN CONSENT.

## Standalone script to generate the local poudriere signing key 
## (self-integrity checking.) 

if [ ! -d /etc/ssl/poudriere ]; then
	mkdir /etc/ssl/poudriere
fi

openssl genrsa -out /etc/ssl/poudriere/self.key 4096
if [ $? -ne 0 ]; then
	echo "[FATAL] Error generating local poudriere key."
	exit 1
fi
chmod 0600 /etc/ssl/poudriere/self.key

openssl rsa -in /etc/ssl/poudriere/self.key -pubout -out /etc/ssl/poudriere/self.pub
if [ $? -ne 0 ]; then
	echo "[FATAL] Error generating public key."
	exit 1
fi
chmod 0755 /etc/ssl/poudriere/self.key
