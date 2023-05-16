# Protect against deliberate exfil and data leak to Google
export GOPROXY=direct
export GOSUMDB=off
export GOTELEMETRY=off

# NOTE: .NET is a non-issue because we don't use the official Microsoft SDK
# except for test builds. And I really, REALLY need that telemetry to be sent
# when musl breaks so I can fix it. -@rootwyrm (member of .NET Foundation)

# XXX: moved to secrets
# XXX: moved to secrets

# TODO: wireguard
# TODO: alias

case $(whoami) in
	root)
		PS1=$PS1
		;;
	talecaster)
		export PATH='/opt/talecaster/bin:$PATH'
		. /opt/talecaster/venv/bin/activate
		if [ ! -z $VIRTUAL_ENV ]; then
			venv_version=$(python --version | awk '{print $2}')
			export PS1='(talecaster) (${venv_version})\n\h:\w\$ '
		else
			export PS1='(talecaster)\n\h:\w\$ '
		fi
		;;
	*)
		PS1=$PS1
		;;
esac
