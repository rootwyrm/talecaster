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
curl -L https://github.com/Sonarr/Sonarr/blob/develop/Logo/64.png > $IMAGEDIR/sonarr.png
## Radarr
curl -L https://github.com/Radarr/Radarr/blob/develop/Logo/64.png > $IMAGEDIR/radarr.png
## Lidarr
curl -L https://github.com/Lidarr/Lidarr/blob/develop/Logo/64.png > $IMAGEDIR/lidarr.png
## Readarr
curl -L https://github.com/Readarr/Readarr/blob/develop/Logo/64.png > $IMAGEDIR/readarr.png
## Mylar
curl -L https://github.com/mylar3/mylar3/blob/v0.6.1/data/images/mylar_logo_128x128.png > $IMAGEDIR/mylar.png

## Nzbget, use their favicon
curl -L https://github.com/nzbget/nzbget/blob/develop/webui/img/favicon-256x256.png > $IMAGEDIR/nzbget.png
## qBittorrent, use their internal www images
## XXX: only a 32x32, need to find a 64x64!
curl -L https://github.com/qbittorrent/qBittorrent/blob/master/src/webui/www/public/images/qbittorrent32.png > $IMAGEDIR/qbittorrent.png
## Prowlarr
curl -L https://github.com/Prowlarr/Prowlarr/blob/develop/Logo/64.png > $IMAGEDIR/prowlarr.png

## Fix permissions
chmod 0755 $IMAGEDIR/*png
