################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		TALECASTER_BASE=${TALECASTER_BASE:-latest}
FROM	ghcr.io/rootwyrm/tc_docker:${TALECASTER_BASE}

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.talecaster.project="tc_nzbget" \
		com.rootwyrm.talecaster.status="%%STATUS%%" \
		com.rootwyrm.talecaster.service="nntp" \
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
EXPOSE	6789/tcp

## Volumes
VOLUME [ "/talecaster/blackhole", "/talecaster/downloads", "/talecaster/config" ]

# vim:sw=4:ts=4
