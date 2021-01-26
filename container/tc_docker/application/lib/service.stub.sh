#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# All rights reserved
# 
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/lib/service.stub.sh

if [ -f /opt/talecaster/id.service ]; then
	/sbin/rc-update add $(cat /opt/talecaster/id.service) default
	exit $?
else
	printf 'No default service identified.\n'
fi
