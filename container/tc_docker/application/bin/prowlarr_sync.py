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
import requests
import json
from argparse import ArgumentParser

prowlarr_key=open('/talecaster/shared/indexer.api').read()

## XXX: Don't like hardcoding like this when we always want defaults.
class Application(object):
    def indirect(self,application):
        method_name=application
        method=getattr(self,method_name,lambda :'Invalid')
        return method()

    def television(self):
        application = 'television'
        application_port = 8989
        sync_categories = "[5000,5010,5020,5030,5040,5045,5050]"
        animesync_categories = "[5070]"
        implementation = 'Sonarr'
        implementationName = 'Sonarr'
        configContract = 'SonarrSettings'
        print('Selected television')

    def movies(self):
        application = 'movies'
        application_port = 7878
        sync_categories = "[2000,2010,2020,2030,2040,2045,2050,2060,2070,2080]"
        implementation = 'Radarr'
        implementationName = 'Radarr'
        configContract = 'RadarrSettings'

    def music(self):
        application = 'music'
        application_port = 8686
        sync_categories = "[3000,3010,3030,3040,3050,3060]"
        implementation = 'Lidarr'
        implementationName = 'Lidarr'
        configContract = 'LidarrSettings'

    def comics(self):
        application = 'comics'
        application_port = 8090
        sync_categories = "[7030]"
        implementation = 'Mylar'
        implementationName = 'Mylar'
        configContract = 'MylarSettings'

def main(args.application):
    endpoint = (str.title(args.application))
    headers = {
        'Content-type': 'application/json',
        'User-Agent': 'rootwyrm/talecaster',
        'X-Api-Key': str(prowlarr_key)
    }
    target = f"http://indexer:9696/indexer/api/v1/applications?"
    print('Updating %s' % endpoint)

    tgt=Application()
    tgt.indirect(args.application)
    ## XXX: A complete and total payload is required for now
    ## Prowlarr/commit/62d15536dfe0933cee1d057b5bd2abe8d6a9bba4
    data = json.JSONEncoder().encode({
        "syncLevel":"fullSync",
        "name":"Sonarr",
        "fields":[
        {
            "name":"prowlarrUrl",
            "value":"http://indexer:9696/indexer"
        },
        {
            "name": "baseUrl",
            "value": f"http://{application}:{application_port}/{application}"
        },
        {
            "name": "apiKey",
            "value": open(f'/talecaster/shared/{application}.api').read()
        },
        {
            "name":"syncCategories",
            "value": sync_categories
        },
        {
            "name":"animeSyncCategories",
            "value": animesync_categories
        }],
        "implementationName": implementationName,
        "implementation": implementation,
        "configContract": configContract,
        "tags":[]
        }
    )
    response = requests.post(target, headers=headers, data=data)
    print('Response %s' % response.status_code)

parser = ArgumentParser(description="Prowlarr application sync")
parser.add_argument("-a", "--app", dest="application", type=str, help="Application to configure", required=True)
args = parser.parse_args()
main(args)
