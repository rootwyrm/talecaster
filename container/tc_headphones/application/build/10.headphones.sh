#!/bin/bash
## application/build/00.install_deps.sh
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
# All rights reserved
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# headphones

. /opt/talecaster/lib/deploy.lib.sh

app_destdir="/opt/talecaster/headphones"
app_git_url="https://github.com/rembo10/headphones.git"
branch="${HP_BRANCH:master}"

ingest_environment
deploy_application_git reinstall 
