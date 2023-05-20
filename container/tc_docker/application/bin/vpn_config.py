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

def main():
    application = open('/opt/talecaster/id.provides').read()
    ## Other scripts require the newline.
    application = application.replace('\n', '')
    log_prefix = "[[bold dark_orange]OpenVPN[/]]"
    vpn_config = os.environ[f"{str.upper(application)}_VPN_CONFIG"]
    print('VPN_config is', vpn_config)
    if os.environ[f"{str.upper(application)}_VPN"] == "true":
        ## VPN should be enabled for this service, regenerate on every run though.
        try:
            open(vpn_config, 'r')
            rich.print(log_prefix, 'Using configuration file', vpn_config)
        except IOError:
            rich.print(log_prefix,'[bold dark_red]FATAL[/]: Could not open', vpn_config)
            sys.exit(2)
        ## Wrap in a try so it bails before trying to run.
        try:
            fh = open('/etc/supervisor.d/openvpn.ini', 'w')
            command = '/usr/sbin/openvpn --connect-retry-max 10 --log /var/log/openvpn.log --writepid /run/openvpn.pid --config ' + vpn_config
            fh.write('[program:openvpn]\n')
            fh.write(f'command={command}\n')
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
            efh = open('/run/openvpn.enable', 'w')
            efh.write('true')
            efh.close()
            ## Warn the user about routing
            rich.print(log_prefix, 'WARNING: local networks may require manual configuration.')
        except:
            rich.print(log_prefix, 'FATAL: Could not write', sini)
    else:
        rich.print(log_prefix, "VPN is not configured for service", application)
        pass
            
main()