################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		TALECASTER_BASE=${TALECASTER_BASE:-latest}
FROM	alpine:3.15 AS inter
WORKDIR	/intermediate
RUN		apk update && apk upgrade && apk add git bash bash-completion build-base curl curl-dev autoconf automake libtool perl python3 python3-dev py3-numpy py3-numpy-dev gcc linux-headers linux-lts-dev && \
	cd /intermediate ; \
	wget -O qbittorrent-nox-static.sh https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/$(uname -m)-qbittorrent-nox
	chmod +x qbittorrent-nox-static.sh ; \
	./qbittorrent-nox-static.sh all

FROM	docker.io/rootwyrm/tc_docker:$TALECASTER_BASE

COPY	--from=inter /intermediate/qbt-build/completed/qbittorrent-nox /usr/local/bin/

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_qbittorrent" \
		com.rootwyrm.status="%%STATUS%%" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
		## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="tc_qbittorrent" \
        org.label-schema.url="%%GITHUB_REPOSITORY%%" \
        org.label-schema.vcs-ref="%%VCS_REF%%" \
        org.label-schema.version="%%REF%%" \
        org.label-schema.build-date="%%RW_BUILDDATE%%" \
        ## OCI
        org.opencontainers.image.authors="RootWyrm" \
        org.opencontainers.image.vendor="RootWyrm" \
        org.opencontainers.image.licenses="CC-BY-NC-4.0" \
        org.opencontainers.image.version="%%RW_VCSHASH%%" \
        org.opencontainers.image.revision="%%GITHUB_SHA%%" \
        org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
        org.opencontainers.image.created="%%RW_BUILDDATE%%" 

## PORTS
EXPOSE	8081/tcp

## VOLUMES
VOLUME	[ "/talecaster/shared" ]
VOLUME	[ "/talecaster/blackhole" ]
VOLUME	[ "/talecaster/downloads" ]

# vim: sw=4:ts=4
