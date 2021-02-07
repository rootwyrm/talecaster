#!/bin/bash
################################################################################
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com>
# All rights reserved
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
# docker/application/build/01.install_user.sh

. /opt/talecaster/lib/talecaster.lib.sh

ingest_environment
deploy_talecaster_user
user_ownership
