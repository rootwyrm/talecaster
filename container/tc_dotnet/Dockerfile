#ARG		RELEASE=latest
#FROM	docker.io/rootwyrm/tc_base:${RELEASE}
FROM	tc_docker

######################################################################
## Labels
######################################################################
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_dotnet" \
		com.rootwyrm.status="%%STATUS%%" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
		## label-schema.org
		org.label-schema.schema-version="1.0.0-rc1" \
		org.label-schema.vendor="RootWyrm" \
		org.label-schema.name="dns_docker/base" \
		org.label-schema.url="%%GITHUB_REPOSITORY%%" \
		org.label-schema.vcs-ref="%%VCS_REF%%" \
		org.label-schema.version="%%REF%%" \
		org.label-schema.build-date="%%RW_BUILDDATE%%" \
		## OCI
		org.opencontainers.image.authors="RootWyrm" \
		org.opencontainers.image.vendor="RootWyrm" \
		org.opencontainers.image.licenses="CC-BY-NC-3.0" \
		org.opencontainers.image.version="%%RW_VCSHASH%%" \
		org.opencontainers.image.revision="%%GITHUB_SHA%%" \
		org.opencontainers.image.source="%%GITHUB_REPOSITORY%%" \
		org.opencontainers.image.created="%%RW_BUILDDATE%%" 

## Common elements
ADD	[ "cron/", "/etc/periodic/" ]
ADD [ "init.d/", "/etc/init.d/" ]
ADD [ "application/", "/opt/talecaster" ]
## Volumes
VOLUME	[ "/run" ]
VOLUME	[ "/shared" ]

## Execute
RUN	apk update && apk upgrade && \
	apk add bash curl libstdc++ libgcc ca-certificates icu libintl && \
	echo "$(date '+%FT%T%z') Installing dotnet..." ; \
	wget https://dotnet.microsoft.com/download/dotnet-core/scripts/v1/dotnet-install.sh && \
	/bin/bash ./dotnet-install.sh --install-dir /opt/dotnet && \
	ln -s /opt/dotnet/dotnet /usr/local/bin/dotnet && \
	dotnet --info && \
	rm ./dotnet-install.sh

ONBUILD RUN	apk update && apk upgrade && \
	touch /firstboot && \
	echo "$(date '+%FT%T%z') [BUILD] phase beginning..." ; \
	for bld in `ls /opt/talecaster/build/ | sort`; do \
		/opt/talecaster/build/$bld ; \
	done && \
	echo "$(date '+%FT%T%z') [BUILD] phase complete..." ; \

