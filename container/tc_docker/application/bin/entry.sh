#!/bin/bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
set -x
. /opt/talecaster/lib/talecaster.lib.sh
. /opt/talecaster/lib/servarr_tools

container_vpn()
{
    ## We actually have to do all this in Python because of the os.env
	## Eventually will just go straight into Python.
    /opt/talecaster/bin/vpn_config.py
}

service_configure()
{
	case $PROVIDES in
		television|movies|music|books)
			xml_generate_from_template /talecaster/config/config.xml
			xml_extract_apikey /talecaster/config/config.xml
			xml_extract_apikey /talecaster/config/config.xml > /talecaster/shared/$PROVIDES.api
			chown $tcuser:$tcgroup /talecaster/config/*
			#> /talecaster/shared/$PROVIDES.api
			;;
		*)
			printf 'not yet implemented\n'
			exit 1
			;;
	esac
}

## Executor
echo "load_config"
load_config
echo "load_pyenv"
load_pyenv
echo "check_base_volumes"
check_base_volumes
echo "check_firstrun"
check_firstrun
echo "deploy_user"
deploy_talecaster_user
echo "fix ownership"
user_ownership
echo "vpn"
container_vpn
echo "service is $PROVIDES"
env
# WARNING: preceding steps must be permitted to fail, so only set -e here so
# that a failure in this stage causes proper bailout.
set -e
echo "enter configure.py"
/opt/talecaster/bin/configure.py

exec /usr/bin/supervisord -n --user 0 -d /run -c /etc/supervisord.conf 
#-e debug 
