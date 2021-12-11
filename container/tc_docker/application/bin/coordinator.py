#!/opt/talecaster/venv/bin/python3
################################################################################
# TaleCaster - https://github.com/rootwyrm/talecaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwrym.com> and its
# contributors, all rights reserved.
#
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

## coordinator.py
## TaleCaster frontend/backend coordinator process

import os
import sys
import requests
import xml.etree.ElementTree as ET
import pyarr

def GetApiKey(self):
    cfgfile = '/talecaster/config/config.xml'
    try:
        open(cfgfile)
        tree = ET.parse(cfgfile)
        for keyval in root.iter('ApiKey'):
            apikey = (keyval.text)
    except Exception as E:
        print('Unable to open configuration file')
        return e

def SonarrApiKey(self):
    apifile = '/talecaster/shared/sonarr.api'
    try:
        sonarrapifile = open(apifile)
        sonarrapi = sonarrapifile.readlines()
    except try:
        GetApiKey()
    except Exception as E:
        print('Unable to open Sonarr API key file')


