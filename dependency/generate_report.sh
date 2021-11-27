#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## dependency/generate_report.sh

if [ ! -f requirements.txt ]; then
	touch requirements.txt
fi

################################################################################
## Python
################################################################################
## TaleCaster internal dependencies
echo "## TaleCaster" > requirements.txt
echo "simplejson" >> requirements.txt
echo "requests" >> requirements.txt 

## Mylar
curl -L https://github.com/mylar3/mylar3/raw/master/requirements.txt >> requirements.txt

################################################################################
## .NET
################################################################################
## Sonarr
if [ ! -d sonarr ]; then
	mkdir sonarr
fi
if [ -d tmp ]; then
	rm -rf tmp
fi
git clone https://github.com/Sonarr/Sonarr.git tmp
find tmp/ -name *.csproj -exec cp {} sonarr \;

## Lidarr
if [ ! -d lidarr ]; then
	mkdir lidarr
fi
if [ -d tmp ]; then
	rm -rf tmp
fi
git clone https://github.com/Lidarr/Lidarr.git tmp
find tmp/ -name *.csproj -exec cp {} lidarr \;

