#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
# All rights reserved
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# docker/application/build/01.install_user.sh

. /opt/talecaster/lib/deploy.lib.sh

ingest_environment
deploy_talecaster_user
deploy_tcuser_ownership
generate_motd
