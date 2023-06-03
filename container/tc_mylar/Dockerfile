################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		TALECASTER_BASE=${TALECASTER_BASE:-latest}
## NOTICE: Mylar's dependencies conflict with TaleCaster's base venv, so it needs it's own
FROM	alpine:3.17 AS pybuild
WORKDIR	/opt/mylar
RUN	apk add --no-cache git bash python3 sqlite && \
	git clone https://github.com/mylar3/mylar3.git . && \
	python3 -m venv /opt/mylar/venv && \
	. /opt/mylar/venv/bin/activate && \
	/opt/mylar/venv/bin/python3 -m pip install --upgrade pip && \
	apk add --no-cache gcc musl-dev python3-dev libjpeg-turbo-dev zlib-dev tiff-dev libwebp-dev lcms2-dev && \
	pip install --no-cache-dir --compile -r requirements.txt

FROM	ghcr.io/rootwyrm/tc_docker:$TALECASTER_BASE

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.talecaster.project="tc_mylar" \
		com.rootwyrm.talecaster.status="%%STATUS%%" \
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
EXPOSE	8090/tcp

## Intermediate
COPY	--from=pybuild /opt/mylar/ /opt/mylar

## Volumes
VOLUME [ "/talecaster/config", "/talecaster/blackhole", "/talecaster/downloads", "/talecaster/comics" ]

# vim:sw=4:ts=4