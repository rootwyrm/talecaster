ARG		ALPINE_BASE=3.13
FROM	alpine:${ALPINE_BASE}

ENV	tcuid=${tcuid:-30000}
ENV tcgid=${tcgid:-30000}
ENV tcuser=${tcuser:-talecaster}
ENV tcgroup=${tcgroup:-media}

## Labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_docker" \
		com.rootwyrm.status="%%STATUS%%" \
		com.rootwyrm.license="CC-BY-NC-4.0" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.vcs.url="%%GITHUB_REPOSITORY%%" \
		## label-schema.org
        org.label-schema.schema-version="1.0.0-rc1" \
        org.label-schema.vendor="RootWyrm" \
        org.label-schema.name="tc_docker" \
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

COPY	[ "application/", "/opt/talecaster/" ]
VOLUME	[ "/sys", "/run", "/shared" ]

RUN	apk update && apk upgrade && \
	apk add --no-cache wget curl file dcron openssl bash openvpn ca-certificates ca-certificates-bundle openrc haveged logrotate && \
	sed -i -e '/^tty*/d' /etc/inittab && \
	sed -i -e '/^# Set up*/d' /etc/inittab && \
	sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
	sed -i -e '/.*salute$/d' /etc/inittab && \
	ln -s /run /var/run && \
	mkdir -p /run/openrc && \
	mkdir -p /run/lock && \
	chown root:uucp /run/lock && \
	mkdir -p /opt/talecaster && \
	mkdir -p /usr/local/src && \
	rm -f /etc/init.d/hw* ; \
	rm -f /etc/init.d/modules ; \
	rm -f /etc/init.d/modules-load ; \
	rm -f /etc/init.d/modloop ; \
	/sbin/rc-update add dcron default ; \
	/sbin/rc-update add haveged default ; \
	sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh ; \
	echo "TaleCaster is Copyright (C) 2016-* Phillip Jaenke and its contributors" > /LICENSE ; \
	echo "https://github.com/rootwyrm/talecaster/" >> /LICENSE ; \
	echo "" >> /LICENSE ; \
	echo "This work is licensed under the Creative Commons Attribution-NonCommerical 4.0 Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA." >> /LICENSE

#COPY [ "rc.conf", "/etc/rc.conf" ]

ONBUILD	ADD [ "application/", "/opt/talecaster/" ]
ONBUILD ADD	[ "init.d/", "/etc/init.d/" ]
ONBUILD ADD [ "cron/", "/etc/periodic/" ]
ONBUILD RUN apk update && apk upgrade && \
	echo "$(date '+%FT%T%z') [BUILD] Beginning build..." ; \
	for bld in `ls /opt/talecaster/build/ | sort`; do \
		/opt/talecaster/build/$bld ; \
	done && \
	echo "$(date '+%FT%T%z') [BUILD] Build complete." \
	/opt/talecaster/lib/service.stub.sh

ENTRYPOINT	[ "/sbin/init" ]
