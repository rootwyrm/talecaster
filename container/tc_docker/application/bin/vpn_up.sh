#!/bin/sh
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/bin/vpn_up.sh

## FYI: This has to be re-run every time the VPN comes up.
## Set resolvers, default to Quad9
TC_RESOLV0="${TC_RESOLV0:-9.9.9.9}"
TC_RESOLV1="${TC_RESOLV1:-149.112.112.112}"

## So, a brief digression. In the name of 'service discovery,' Docker does a
#  lot of incredibly stupid, wrong, and outright broken things with DNS. How
#  broken? DNSSEC is completely compromised. This is obviously not simply bad,
#  but the height of incompetence. And this insecurity is forced.
#  It also means that without doing some serious manipulation here, DNS will 
#  leak like a damn sieve. Because it proxies the external request through the
#  non-VPN'd host! Idiots. As is, this would still end up leaking because of the
#  forced service-discovery crap. And 127.0.0.11 will never, ever not attempt a
#  lookup. Even if an authoritative NX should have been cached.
#
#  Moral of the story? Learn to do DNS correctly or don't do it at all.

cp /etc/resolv.conf /etc/resolv.conf.bak
## Anyway, rewrite our resolv.conf in-place because Docker locks it. 
cat /dev/null > /etc/resolv.conf
echo "nameserver ${TC_RESOLV0}" >> /etc/resolv.conf
echo "nameserver ${TC_RESOLV1}" >> /etc/resolv.conf
echo "nameserver 127.0.0.11" >> /etc/resolv.conf
echo "options ndots:0" >> /etc/resolv.conf

## Restart our service so that it picks up interfaces correctly.
SERVICE=$(cat /opt/talecaster/id.service)
service stop $SERVICE && sleep 5 && service start $SERVICE
