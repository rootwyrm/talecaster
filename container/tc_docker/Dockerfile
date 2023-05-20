################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################
ARG		ALPINE_BASE=${ALPINE_BASE:-3.17}

################################################################################
# Build and package unrar
################################################################################
FROM	alpine:${ALPINE_BASE} AS prebuild
WORKDIR	/opt/work
RUN		apk update && apk upgrade && \
	apk add make g++ && \
	wget https://www.rarlab.com/rar/unrarsrc-6.2.6.tar.gz && \
	tar xf unrarsrc-6.2.6.tar.gz && \
	cd unrar && \
	make 

################################################################################
# Actual base image
################################################################################
FROM	alpine:${ALPINE_BASE}

ENV tcuid=${tcuid:-30000}
ENV tcgid=${tcgid:-30000}
ENV tcuser=${tcuser:-talecaster}
ENV tcgroup=${tcgroup:-media}

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.talecaster.project="tc_docker" \
		com.rootwyrm.talecaster.status="%%STATUS%%" \
		com.rootwyrm.talecaster.service="base" \
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

#ADD		[ "init.d/", "/etc/init.d/" ]
RUN	apk update && apk upgrade && \
	apk add --no-cache wget curl file grep dcron openssl bash ca-certificates ca-certificates-bundle supervisor logrotate tzdata jq rsyslog python3 uuidgen && \
	sed -i -e '/^tty*/d' /etc/inittab && \
	sed -i -e '/^# Set up*/d' /etc/inittab && \
	sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
	sed -i -e '/.*salute$/d' /etc/inittab && \
	ln -s /run /var/run && \
	mkdir -p /opt/talecaster && \
	mkdir -p /usr/local/src 

ADD		[ "cron/", "/etc/periodic/" ]
COPY	[ "application/", "/opt/talecaster/" ]
COPY	--from=prebuild /opt/work/unrar/unrar /usr/local/bin/unrar
COPY	--from=prebuild /opt/work/unrar/license.txt /usr/local/bin/unrar.license.txt
COPY 	[ "etc/", "/etc/" ]
VOLUME	[ "/run", "/talecaster/shared" ]

RUN	python3 -m venv /opt/talecaster/venv ; \
	. /opt/talecaster/venv/bin/activate ; \
	/opt/talecaster/venv/bin/python3 -m pip install --upgrade pip && \
	/opt/talecaster/venv/bin/pip install -r /opt/talecaster/venv/requirements.txt && \
	## Retrieve license text file direct from CreativeCommons
	wget -O /LICENSE https://creativecommons.org/licenses/by-nc/4.0/legalcode.txt 


ONBUILD	ADD [ "application/", "/opt/talecaster/" ]
ONBUILD ADD	[ "etc/", "/etc/" ]
ONBUILD RUN touch /firstboot ; \
	echo "$(date '+%FT%T%z') [BUILD] Beginning build..." ; \
	for bld in `ls /opt/talecaster/build/ | sort`; do \
		/opt/talecaster/build/$bld ; \
	done && \
	echo "$(date '+%FT%T%z') [BUILD] Build complete." 

#ENTRYPOINT	[ "/sbin/init" ]
ENTRYPOINT [ "/opt/talecaster/bin/entry.sh" ]
