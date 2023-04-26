################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		TALECASTER_BASE=${TALECASTER_BASE:-latest}
FROM	ghcr.io/rootwyrm/tc_docker:$TALECASTER_BASE

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.talecaster.project="tc_frontend" \
		com.rootwyrm.talecaster.status="%%STATUS%%" \
		com.rootwyrm.talecaster.service="frontend" \
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

RUN	apk update && apk upgrade && \
	apk add --no-cache logrotate nginx nginx-mod-http-cache-purge nginx-mod-http-headers-more nginx-mod-http-cookie-flag ; \
	/sbin/rc-update add nginx default

COPY [ "etc/", "/etc/" ]