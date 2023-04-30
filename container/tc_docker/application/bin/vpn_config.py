#!/opt/talecaster/venv/bin/python3
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

import os
import sys
import rich

sini = "/etc/supervisor.d/openvpn.ini"

def main():
    application = open('/opt/talecaster/id.provides').read()
    ## Other scripts require the newline.
    application = application.replace('\n', '')
    vpn_config = f"{str.upper(application)}_VPN_CONFIG"
    if vpn_config in os.environ:
        ## VPN should be enabled for this service, regenerate on every run though.
        try:
            os.open(vpn_config, 'r')
            rich.print('[bold dark_orange]OpenVPN[/] Using configuration file', vpn_config)
        except:
            rich.print(f'[bold dark_orange]OpenVPN[/] FATAL: Could not open', vpn_config)
            sys.exit(2)
        ## Wrap in a try so it bails before trying to run.
        try:
            fh = open(sini, 'w')
            fh.write('[program:openvpn]\n')
            fh.write(f'/usr/sbin/openvpn --connect-retry-max 10 --log /var/log/openvpn.log --writepid /run/openvpn.pid --config ',os.environ[vpn_config].read(),'\n')
            fh.write('process_name=%(program_name)s\n')
            fh.write('numprocs=1\n')
            fh.write('directory=/talecaster/shared\n')
            fh.write('user=root\n')
            fh.write('umask=022\n')
            fh.write('autostart=true\n')
            fh.write('startsecs=10\n')
            fh.write('startretries=2\n')
            fh.write('autorestart=unexpected\n')
            fh.write('stopasgroup=true\n')
            fh.close()
            efh = open('/run/openvpn.enable')
            efh.write('true')
            efh.close()
        except:
            rich.print(f'[[bold dark_orange]OpenVPN[/]]: FATAL: Could not write', sini)
    else:
        rich.print(f'[[bold dark_orange]OpenVPN[/]]: not configured for service', application)
        pass
            
main()