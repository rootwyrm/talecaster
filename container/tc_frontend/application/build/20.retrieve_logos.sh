#!/usr/bin/env bash
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
## build/20.retrieve_logos.sh

. /opt/talecaster/lib/talecaster.lib.sh

## Special script to retrieve logos directly from upstream
export IMAGEDIR="/opt/talecaster/html/images"

## Sonarr
curl -L https://github.com/Sonarr/Sonarr/raw/develop/Logo/64.png > $IMAGEDIR/sonarr.png
## Radarr
curl -L https://github.com/Radarr/Radarr/raw/develop/Logo/64.png > $IMAGEDIR/radarr.png
## Lidarr
curl -L https://github.com/Lidarr/Lidarr/raw/develop/Logo/64.png > $IMAGEDIR/lidarr.png
## Readarr
curl -L https://github.com/Readarr/Readarr/raw/develop/Logo/64.png > $IMAGEDIR/readarr.png
## Mylar
curl -L https://github.com/mylar3/mylar3/raw/v0.6.1/data/images/mylar_logo_128x128.png > $IMAGEDIR/mylar.png
## Bazarr 

## Nzbget, use their favicon
curl -L https://github.com/nzbget/nzbget/raw/develop/webui/img/favicon-256x256.png > $IMAGEDIR/nzbget.png
## qBittorrent, use their internal www images
## XXX: only a 32x32, need to find a 64x64!
curl -L https://github.com/qbittorrent/qBittorrent/raw/master/src/webui/www/public/images/qbittorrent32.png > $IMAGEDIR/qbittorrent.png
## Prowlarr
curl -L https://github.com/Prowlarr/Prowlarr/raw/develop/Logo/64.png > $IMAGEDIR/prowlarr.png
## Bazarr, use from their website
curl -L https://www.bazarr.media/assets/img/logo.png > $IMAGEDIR/bazarr.png

## Fix permissions
chmod 0755 $IMAGEDIR/*png
