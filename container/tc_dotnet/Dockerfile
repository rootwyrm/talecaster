ARG		RELEASE=latest
FROM	docker.io/rootwyrm/tc_docker:${RELEASE}

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
ADD [ "application/", "/opt/talecaster" ]
## Volumes

## Execute
ENV	DOTNET_VERSION=5.0.3
RUN	echo "$(date '+%FT%T%z') Installing dotnet..." ; \
	apk update && apk upgrade && \
	apk add libstdc++ libgcc libc6-compat gcompat ; \
	wget -O /opt/talecaster/dotnet.tgz https://dotnetcli.azureedge.net/dotnet/Runtime/$DOTNET_VERSION/dotnet-runtime-$DOTNET_VERSION-linux-musl-x64.tar.gz \
    && dotnet_sha512='85e4063792fb9d921a24f9da221a2b69c1faa253adb10644cc5907c35af92b3204f461fd6a9ec936ae37cfada47937f1c2b67174eabc778bd7305d66dc67e340' \
    && echo "$dotnet_sha512  /opt/talecaster/dotnet.tgz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -C /usr/share/dotnet -oxzf /opt/talecaster/dotnet.tgz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
	&& rm -f /opt/talecaster/dotnet.tgz ; \
	echo "$(date '+%FT%T%z') Dotnet installation complete..." 

ONBUILD RUN	apk update && apk upgrade && \
	touch /firstboot && \
	echo "$(date '+%FT%T%z') [BUILD] phase beginning..." ; \
	for bld in `ls /opt/talecaster/build/ | sort`; do \
		/opt/talecaster/build/$bld ; \
	done && \
	echo "$(date '+%FT%T%z') [BUILD] phase complete..." 
