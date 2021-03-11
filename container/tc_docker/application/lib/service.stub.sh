#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# tc_docker/application/lib/service.stub.sh

if [ -f /opt/talecaster/id.service ]; then
	/sbin/rc-update add $(cat /opt/talecaster/id.service) default
	exit $?
else
	printf 'No default service identified.\n'
fi
