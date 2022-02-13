#!/opt/talecaster/venv/bin/python
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

## Ingest key values
tcuser = os.environ['tcuser']
tcgroup = os.environ['tcgroup']
tcuid = os.environ['tcuid']
tcgid = os.environ['tcgid']

class SelectApplication(object):
    def __init__(self, application):
        self.application = args.application
   
    ## Sonarr
    def television(self):
        self.application = 'television'
        self.application_port = os.environ['TELEVISION_PORT']
        self.sync_categories = [5000,5010,5020,5030,5040,5045,5050]
        self.animesync_categories = [5070]
        self.implementation = 'Sonarr'
        self.implementationName = 'Sonarr'
        self.configContract = 'SonarrSettings'
        self.api = 'api/v3'
        self.client_category = 'tvCategory'
        self.recent_priority = 'recentTvPriority'
        self.older_priority = 'olderTvPriority'
   
    ## Radarr
    def movies(self):
        self.application = 'movies'
        self.application_port = os.environ['MOVIES_PORT']
        self.sync_categories = [2000,2010,2020,2030,2040,2045,2050,2060,2070,2080]
        self.animesync_categories = []
        self.implementation = 'Radarr'
        self.implementationName = 'Radarr'
        self.configContract = 'RadarrSettings'
        self.api = 'api/v3'
        self.client_category = 'movieCategory'
        self.recent_priority = 'recentMoviePriority'
        self.older_priority = 'olderMoviePriority'
    
    ## Lidarr 
    def music(self):
        self.application = 'music'
        self.application_port = os.environ['MUSIC_PORT']
        self.sync_categories = [3000,3010,3030,3040,3050,3060]
        self.animesync_categories = []
        self.implementation = 'Lidarr'
        self.implementationName = 'Lidarr'
        self.configContract = 'LidarrSettings'
        self.api = 'api/v1'
        self.client_category = 'musicCategory'
        ## XXX: Upstream fix is still pending
        self.recent_priority = 'recentTvPriority'
        self.older_priority = 'olderTvPriority'
    
    ## Readarr
    def books(self):
        self.application = 'books'
        self.application_port = os.environ['BOOKS_PORT']
        self.sync_categories = [3030,7000,7010,7020,7030,7040,7050,7060]
        self.animesync_categories = []
        self.implementation = 'Readarr'
        self.implementationName = 'Readarr'
        self.configContract = 'ReadarrSettings'
        self.api = 'api/v1'
        ## XXX: Upstream fix is still pending
        self.client_category = 'musicCategory'
        self.recent_priority = 'recentTvPriority'
        self.older_priority = 'olderTvPriority'
    
    ## XXX: Mylar
    ## We don't actually use the Mylar API because of limited functionality. 
    def comics(self):
        self.application = 'comics'
        self.application_port = os.environ['COMICS_PORT']
        self.sync_categories = [7030]
        self.animesync_categories = []
        self.implementation = 'Mylar'
        self.implementationName = 'Mylar'
        self.configContract = 'MylarSettings'
        self.api = 'api/v1'
        ## XXX: Upstream fix is still pending
    
    ## Prowlarr 
    def indexer(self):
        self.application = 'indexer'
        self.application_port = os.environ['INDEXER_PORT']
        self.sync_categories = []
        self.animesync_categories = []
        self.implementation = 'Prowlarr'
        self.implementationName = 'Prowlarr'
        self.configContract = 'ProwlarrSettings'
        self.api = 'api/v1'
        self.client_category = ''

## Add nzbget client to a Servarr application only
def add_nzbget_client(args):
    tgt=SelectApplication()
    tgt.indirect(args.application)
    nntp_user = os.environ['NNTP_USER']
    nntp_pass = os.environ['NNTP_PASSWORD']
    nntp_port = os.environ['NNTP_PORT']
    nntp_category = (str.title(tgt.application))

    apikeypath = f'/talecaster/shared/{tgt.application}.api'
    apikey = open(apikeypath).read()

    ## Sonarr is v3??
    target = f"http://{tgt.application}:{tgt.application_port}/{tgt.application}/{tgt.api}/downloadclient?"
    headers = {
        'Content-type': 'application/json',
        'User-Agent': 'rootwyrm/talecaster',
        'X-Api-Key': str(apikey)
    }

    data = json.JSONEncoder().encode({
        "enable": true,
        "protocol": "usenet",
        "priority": 1,
        "removeCompletedDownloads": True,
        "removeFailedDownloads": True,
        "name": "TaleCaster - NZBget",
        "implementationname": "NZBGet",
        "implementation": "Nzbget",
        "configContract": "NzbgetSettings",
        "fields": [ 
            { 
                "name": "host",
                "value": "nntp"
            },
            {
                "name": "port",
                "value": nntp_port
            },
            {
                "name": "useSsl",
                "value": False
            },
            {
                "name": "urlBase"
            },
            {
                "name": tgt.category,
                "value": nntp_category
            },
            { "name": tgt.recent_category, "value": 0 },
            { "name": tgt.older_category, "value": 0 },
            { "name": "addPaused", "value": False }
        ],
        "tags": []
    })

    try:
        requests.post(target, headers=headers, data=data)
    except:
        printf('Update of %s failed %s' % tgt.application % response.status_code)

def main(args):
    if args.blackhole:
        add_blackhole_client(args)
    if args.download:
        if args.client == 'nzbget':
            add_download_nzbget(args)
        if args.client == 'torrent':
            add_download_torrent(args)
    else:
        print('Insufficient arguments')
        return 1
            

parser = ArgumentParser(description="TaleCaster Servarr Tool")
parser.add_argument("-a", "--app", dest="application", type=str, help="Application to configure", required=True)
parser.add_argument("-b", "--blackhole", dest="blackhole", type=str, help="Configure blackhole directory", required=False)
parser.add_argument("-d", "--download", dest="download", type=BooleanOptionalAction, help="Configure a download client", required=False)
parser.add_argument("-c", "--client", dest="client", type=str, help="Download client to configure", required=False)
