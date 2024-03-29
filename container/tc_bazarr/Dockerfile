################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		TALECASTER_BASE=${TALECASTER_BASE:-latest}
FROM	alpine:3.16 AS pybuild
WORKDIR	/opt/bazarr
RUN		apk update && apk upgrade && \
	apk add git bash python3 sqlite && \
	apk add libxml2-dev libxslt-dev python3-dev unrar ffmpeg && \
	cd /opt/bazarr ; wget https://github.com/morpheus65535/bazarr/releases/latest/download/bazarr.zip && \
	cd /opt/bazarr && unzip -q bazarr.zip && rm bazarr.zip && \
	python3 -m venv /opt/bazarr/venv && \
	. /opt/bazarr/venv/bin/activate && \
	/opt/bazarr/venv/bin/python3 -m pip install --upgrade pip && \
	pip install --no-cache-dir wheel && \
	apk add gcc g++ musl-dev python3-dev && \
	pip install --no-cache-dir --compile -r /opt/bazarr/requirements.txt 
	
	#apk add gcc musl-dev python3-dev libjpeg-turbo-dev zlib-dev tiff-dev libwebp-dev lcms2-dev && \

FROM	ghcr.io/rootwyrm/tc_docker:$TALECASTER_BASE

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.talecaster.branch="%%STATUS%%" \
		com.rootwyrm.talecaster.product="tc_mylar" \
		com.rootwyrm.talecaster.service="comics" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
		## OCI
        org.opencontainers.image.created="%%RW_BUILDDATE%%" \
        org.opencontainers.image.url="https://github.com/rootwyrm/talecaster" \
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-4.0" \
        org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
        org.opencontainers.image.version="%%RW_VCSHASH%%" \
        org.opencontainers.image.revision="%%GITHUB_SHA%%"

## Ports
EXPOSE	6767/tcp

## Intermediate
COPY	--from=pybuild /opt/bazarr/ /opt/bazarr

## Volumes
VOLUME [ "/talecaster/config", "/talecaster/blackhole", "/talecaster/downloads", "/talecaster/comics" ]

# vim:sw=4:ts=4
