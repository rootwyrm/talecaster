FROM	alpine:3.8

MAINTAINER	Phillip "RootWyrm" Jaenke <talecaster@rootwyrm.com>

## Set up our labels
LABEL	com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_docker" \
		com.rootwyrm.status="" \
		com.rootwyrm.vcs-type="github" \
		com.rootwyrm.changelog-url="https://github.com/rootwyrm/talecaster/CHANGELOG" \
		com.rootwyrm.nvd.release="0" \
		com.rootwyrm.nvd.version="0" \
		com.rootwyrm.nvd.update="0" \
		com.rootwyrm.nvd.update_sub="$RW_BLDHASH" \
		com.rootwyrm.nvd.build_time=$LS_BLDDATE \
		# Talecaster Settings
		com.rootwyrm.talecaster.provides="$TC_PROVIDES" \
		com.rootwyrm.talecaster.depends="" \
		com.rootwyrm.talecaster.service="$TC_SERVICE" \
		com.rootwyrm.talecaster.ports_tcp="" \
		com.rootwyrm.talecaster.ports_udp="" \
		com.rootwyrm.talecaster.synology="0" \
		com.rootwyrm.talecaster.qnap="0" \
		com.rootwyrm.talecaster.vpn="1" \
		# Label Schema
		org.label-schema.schema-version="$LS_SCHEMAVERSION" \
		org.label-schema.vendor="$LS_VENDOR" \
		org.label-schema.name="$LS_NAME" \
		org.label-schema.url="$LS_URL" \
		org.label-schema.vcs-ref="$VCS_REF" \
		org.label-schema.version="$RW_VCSHASH" \
		org.label-schema.build-date=$LS_BLDDATE

ENV pkg_common="runit file dcron apk-cron openssl bash openvpn"

## Create common elements
COPY [ "application/", "/opt/talecaster" ]
COPY [ "sv/", "/etc/sv" ]
RUN mkdir -p /opt/talecaster/defaults && \
	mkdir -p /opt/talecaster/build && \
	mkdir -p /var/log/runit && \
	touch /firstboot ; \
	apk update && \
	apk upgrade && \
	export pkg_common="runit file dcron apk-cron openssl bash openvpn" && \
	apk add --no-cache $pkg_common && \
	ln -s /etc/sv/firstboot /etc/service/ && \
	ln -s /etc/service /service && \
	sed -i -e '/^tty*/d' /etc/inittab && \
	sed -i -e '/^# Set up*/d' /etc/inittab && \
	sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
	sed -i -e '/.*salute$/d' /etc/inittab && \
	rm -rf /etc/init.d

VOLUME [ "/run", "/config/openvpn", "/shared", "/downloads" ]

## Handle rebuilds in a nicer fashion. 
ONBUILD RUN apk update ; apk upgrade

## To go to edge (rarely needed):
# FROM alpine:edge
# http://dl-cdn.alpinelinux.org/alpine/edge/main
# http://dl-cdn.alpinelinux.org/alpine/edge/community
# http://dl-cdn.alpinelinux.org/alpine/edge/testing
# FROM alpine:3.x
# http://dl-cdn.alpinelinux.org/alpine/v3.5/main
# http://dl-cdn.alpinelinux.org/alpine/v3.5/community
# http://dl-cdn.alpinelinux.org/alpine/v3.5/testing
