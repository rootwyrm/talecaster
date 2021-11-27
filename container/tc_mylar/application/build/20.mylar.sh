#!/bin/bash
## application/build/00.install_deps.sh
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
# All rights reserved
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# application/build/20.mylar.sh

. /opt/talecaster/lib/talecaster.lib.sh

## We pre-installed
export app_name="Mylar"
export app_url="https://github.com/mylar3/mylar3"
export app_destdir="/opt/mylar"

# XXX: noop for now
#ingest_environment
#deploy_application_git reinstall 
