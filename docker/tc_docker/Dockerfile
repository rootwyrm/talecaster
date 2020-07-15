FROM	alpine:3.12

MAINTAINER	Phillip "RootWyrm" Jaenke <talecaster@rootwyrm.com>

## Set up our labels
LABEL	maintainer="Phillip 'RootWyrm' Jaenke <talecaster@rootwyrm.com>" \
		com.rootwyrm.product="TaleCaster" \
		com.rootwyrm.project="tc_docker" \
		com.rootwyrm.status="" \
		com.rootwyrm.vcs-type="github" \
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

## Create common elements
COPY [ "application/", "/opt/talecaster" ]
COPY [ "sv/", "/etc/sv" ]
RUN	apk update && \
	apk upgrade && \
	mkdir -p /opt/talecaster/defaults && \
	mkdir -p /opt/talecaster/build && \
	apk add --no-cache runit file dcron apk-cron openssl bash openvpn ca-certificates ca-certificates-bundle openrc && \
	ln -s /etc/sv/firstboot /etc/service/ && \
	ln -s /etc/service /service && \
	sed -i -e '/^tty*/d' /etc/inittab && \
	sed -i -e '/^# Set up*/d' /etc/inittab && \
	sed -i -e '/^::ctrlalt*/d' /etc/inittab && \
	sed -i -e '/.*salute$/d' /etc/inittab

VOLUME [ "/run", "/config/openvpn", "/shared", "/downloads" ]

## Handle rebuilds in a nicer fashion. 
ONBUILD ADD	[ "application/", "/opt/talecaster" ]
ONBUILD ADD [ "init.d/", "/etc/init.d" ]
ONBUILD RUN touch /firstboot && \
	echo "$(date '+%FT%T%z') [BUILD] Build phase beginning..." ; \
	for bld in `ls /opt/talecaster/build/ | sort`; do \
		/opt/talecaster/build/$bld && \
	done && \
	echo "$(date '+%FT%T%z') [BUILD] Build phase complete." 
	#/sbin/rc-update add $(cat /opt/talecaster/id.service) default

#ENTRYPOINT [ "/sbin/init" ]
