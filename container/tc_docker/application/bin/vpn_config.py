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

initd = "/etc/init.d/openvpn.talecaster"
confd = "/etc/conf.d/openvpn.talecaster"

def main():
    application = open('/opt/talecaster/id.provides').read()
    ## Other scripts require the newline.
    application = application.replace('\n', '')
    vpn_var = f"{str.upper(application)}_VPN"
    if str.upper(os.environ[vpn_var]) == 'TRUE':
        ## VPN should be enabled for this service
        try:
            os.symlink("/etc/init.d/openvpn", initd)
        except:
            print("Failed to create symlink for %s" % initd)
            return 255
        ## XXX: Need a better check on this
        vpncfgvar = f"{vpn_var}_CONFIG"
        if os.environ[vpncfgvar] is None:
            print("No %s defined, cannot continue!" % vpncfgvar)
            return 1
        ## Now we have to create our conf.d file
        try:
            fh = open(confd, 'w')
            fh.write('detect_client="YES"\n')
            fh.write(f'cfgfile=/talecaster/shared/{os.environ[vpncfgvar]}\n')
            ## Avoid using Docker's internal resolver, leaky and broken
            fh.write('peer_dns="yes"\n')
            ## NYI: vpn_up.sh needs rewritten
            #fh.write('up_script="/opt/talecaster/bin/vpn_up.sh"')
        except:
            print("Unable to write configuration file %s" % confd)
            return 255
        ## Now update the rc
        rcupd = os.system("rc-update add openvpn.talecaster")
        if rcupd != 0:
            print("Error adding openvpn.talecaster to startup.")
            return 255

main()
