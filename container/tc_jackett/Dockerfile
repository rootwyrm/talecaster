################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG     TALECASTER_BASE=latest
## XXX: Temporary 
## See https://github.com/Jackett/Jackett/issues/11969
FROM    mcr.microsoft.com/dotnet/sdk:5.0-alpine-amd64 AS build
WORKDIR /artifact
RUN     apk update && apk upgrade && apk add git bash build-base linux-headers && \
        cd /artifact && \
        export JVER="0.18.402" && \
        wget https://github.com/Jackett/Jackett/archive/refs/tags/v0.18.402.tar.gz && \
        tar xf v0.18.402.tar.gz && \
        cd Jackett-0.18.402 && \
        dotnet restore src/Jackett.Server -f -r linux-musl-x64 && \
        dotnet publish src/Jackett.Server -f net5.0 -r linux-musl-x64 --force -c Release -o /artifact/build

FROM	docker.io/rootwyrm/tc_docker:$TALECASTER_BASE
## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_jackett" \
		com.rootwyrm.status="%%STATUS%%" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
		## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="tc_jackett" \
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

## XXX: Temporary
COPY    --from=build /artifact/build/* /opt/Jackett/

## Ports
EXPOSE	9117/tcp

## Volumes
VOLUME [ "/talecaster/blackhole", "/talecaster/config" ]

# vim:sw=4:ts=4:et
