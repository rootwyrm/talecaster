################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* its contributors, all rights reserved
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

import TaleCaster
import os
import sys
import time
import threading
import subprocess
import concurrent.futures
import logging
import queue
import rich
from subprocess import PIPE, TimeoutExpired
from rich.logging import RichHandler
from rich.pretty import pprint
from rich.console import Console

## Run firstboot operations
def firstboot():
    ## XXX: single-step for now to ease debugging
    if os.environ["tcuser"] is None:
        print("tcuser undefined!")
        os._exit(99)
    if os.environ["tcuid"] is None:
        print("tcuid is undefined!")
        os._exit(99)
    if os.environ["tcgroup"] is None:
        print("tcgroup is undefined!")
        os._exit(99)
    if os.environ["tcgid"] is None:
        print("tcgid is undefined")
        os._exit(99)
    #endif
    
    ## User creation
    tcuser=str(os.environ["tcuser"])
    tcgroup=str(os.environ["tcgroup"])
    tcuid=int(os.environ["tcuid"])
    tcgid=int(os.environ["tcgid"])
    createuser(tcuser,tcuid,tcgroup,tcgid)
    permission_repair(tcuid,tcgid)

## NYI: needs existing user check and improved error handling
def createuser(tcuser,tcuid,tcgroup,tcgid):
    ## Do group first
    print("Adding group %s with gid %s" % (tcgroup, tcgid))
    cgroup = os.system(f"/usr/sbin/addgroup -g {tcgid} {tcgroup}")
    if cgroup != 0:
        print("Error creating group %s" % tcgroup)
    print("Adding user %s with uid %s" % (tcuser, tcuid))
    cuser = os.system(f"/usr/sbin/adduser -h /home/{tcuser} -g 'TaleCaster User' -u {tcuid} -G {tcgroup} -D -s /bin/bash {tcuser}")
    if cuser != 0:
        print("Error creating user %s" % tcuser)

## Repair permissions on static directories
## XXX: Missing permission repair on service storage directory
def permission_repair(tcuid,tcgid):
    for path in [ '/talecaster/config', '/talecaster/shared', '/talecaster/blackhole', '/talecaster/downloads' ]:
        print("Setting ownership on %s" % path)
        for dirpath, dirnames, filenames in os.walk(path):
            os.chown(dirpath, uid=tcuid, gid=tcgid)
            for filename in filenames:
                os.chown(os.path.join(dirpath, filename), uid=tcuid, gid=tcgid)

## XXX: Reserved for Dragon North MediaBox
def dragonnorth_mediabox():
    ## XXX: RESERVED: BD-ROM device check and init
    ## XXX: RESERVED: BD-ROM device key update
    return None

def __main__():
    ## Constants
    global prefix_openvpn
    global prefix_talecaster
    prefix_openvpn = "[[bold dark_orange]OpenVPN[/]]"
    prefix_talecaster = "[[bold dark_blue]TaleCaster[/]]"
    openvpn_queue = queue.Queue()
    service_queue = queue.Queue()

    global console
    console = Console()

    ## Perform firstboot
    firstboot_check = os.path.exists('/firstboot')
    if firstboot_check is True:
        rich.print(prefix_talecaster, "Beginning firstboot procedures...")
        firstboot()

    try:
        global service
        service = open('/opt/talecaster/id.provides', 'r').read()
        global prefix_service
        prefix_service = f"[[bold green]]{service}[/]]"
    except:
        rich.print(prefix_talecaster, "[bold red]FATAL:[/] No application defined!")
        os._exit(255)
    ## Fix the service by removing newline internally. It needs to remain in the original
    service = service.replace('\n','')

    ## OpenVPN
    ## Enable around the _CONFIG being non-null
    openvpn_enable = f"{str.upper(service)}_VPN_CONFIG"
    if openvpn_enable not in os.environ:
        rich.print(prefix_openvpn, "OpenVPN not enabled.")
        pass
    else:
        import netifaces 
        from netifaces import AF_LINK, AF_INET
        rich.print(prefix_openvpn, "using configuration", os.environ[openvpn_enable])
        openvpn_config = os.environ[openvpn_enable]
        thread_openvpn = threading.Thread(target=TaleCaster.TaleCaster_run_openvpn, args=(openvpn_config, openvpn_queue,), daemon=False, name="openvpn")
        thread_openvpn.start()
        ## Wait for OpenVPN to be up before starting applications.
        while thread_openvpn.is_alive() is not True:
            pprint(thread_openvpn)
            pprint(thread_openvpn.is_alive())
            rich.print(prefix_openvpn, "connection still starting...")
            time.sleep(1)
        ## Give OpenVPN time to settle.
        vpn_active = None
        while vpn_active is None:
            if 'tun0' not in netifaces.interfaces():
                rich.print(prefix_openvpn, "tun0 not ready yet.")
                time.sleep(2)
            else:
                vpn_active = True

    print(TaleCaster)
    app = TaleCaster.TaleCasterApplication()
    app.indirect(service)

    ## Service
    thread_service = threading.Thread(target=TaleCaster.TaleCaster_run_service, args=(service, service_queue,), daemon=False, name="service")
    try:
        thread_service.start()
    except:
        rich.print(prefix_talecaster, "[bold red]FATAL:[/] Unable to start service thread!")
        os._exit(2)

    print("get from queue")
    ## XXX: Needs to be a log handler for prefixing, probably
    while not service_queue.empty():
        prefix_service = "[[bold green] {service}[/]]"
        service_msg = service_queue.get()
        rich.print(prefix_service, service_msg)

__main__()