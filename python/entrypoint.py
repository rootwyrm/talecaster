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
from subprocess import PIPE, TimeoutExpired
from rich.logging import RichHandler
from rich.pretty import pprint

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
    global talecaster_prefix
    talecaster_prefix = "[[bold dark_blue]TaleCaster[/]]"
    process_queue = queue.Queue()

    ## Perform firstboot
    firstboot_check = os.path.exists('/firstboot')
    if firstboot_check is True:
        print(f"{talecaster_prefix} Beginning firstboot procedures...")
        firstboot()

    try:
        global service
        service = open('/opt/talecaster/id.provides', 'r').read()
    except:
        print(f"{talecaster_prefix} [bold red]FATAL:[/] No application defined!")
        os._exit(255)
    ## Fix the service by removing newline internally. It needs to remain in the original
    service = service.replace('\n','')

    ## OpenVPN
    ## XXX: NYI

    ## Service
    thread_service = threading.Thread(target=TaleCaster_run_service, args=(service, process_queue,), daemon=False, name="service")
    try:
        thread_service.start()
    except:
        print(f"{talecaster_prefix} [bold red]FATAL:[/] Unable to start service thread!")
        os._exit(2)

    thread_service.join()
    stdout, stderr, returncode = process_queue.get()

    while not process_queue.empty():
        communicate = process_queue.get()
        print(communicate)