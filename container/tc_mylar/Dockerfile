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
WORKDIR	/opt/mylar
RUN		apk update && apk upgrade && \
	apk add git bash python3 sqlite && \
	cd /opt/mylar ; git clone https://github.com/mylar3/mylar3.git . && \
	python3 -m venv /opt/mylar/venv && \
	. /opt/mylar/venv/bin/activate && \
	/opt/mylar/venv/bin/python3 -m pip install --upgrade pip && \
	apk add gcc musl-dev python3-dev libjpeg-turbo-dev zlib-dev tiff-dev libwebp-dev lcms2-dev && \
	pip install --no-cache-dir --compile -r requirements.txt

FROM	ghcr.io/rootwyrm/tc_docker:$TALECASTER_BASE

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_mylar" \
		com.rootwyrm.status="%%STATUS%%" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
        ## OCI
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-4.0" \
        org.opencontainers.image.version="%%RW_VCSHASH%%" \
        org.opencontainers.image.revision="%%GITHUB_SHA%%" \
        org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
        org.opencontainers.image.created="%%RW_BUILDDATE%%" 

## Ports
EXPOSE	8090/tcp

## Intermediate
COPY	--from=pybuild /opt/mylar/ /opt/mylar

## Volumes
VOLUME [ "/talecaster/config", "/talecaster/blackhole", "/talecaster/downloads", "/talecaster/comics" ]

# vim:sw=4:ts=4
