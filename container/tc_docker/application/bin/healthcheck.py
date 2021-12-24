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

class Application(object):
    def indirect(self,application):
        method_name=application
        method=getattr(self,method_name,lambda :'Invalid')
        return method()

    def television(self):
        self.application = 'television'
        self.application_port = 8989
        self.apikey=open(f'/talecaster/shared/{self.application}.api').read()
        self.healthcheck = 'api/v3/system/status'

    def movies(self):
        self.application = 'movies'
        self.application_port = 7878
        self.apikey=open(f'/talecaster/shared/{self.application}.api').read()
        self.healthcheck = 'api/v3/system/status'

    def music(self):
        self.application = 'music'
        self.application_port = 8686
        self.apikey=open(f'/talecaster/shared/{self.application}.api').read()
        self.healthcheck = 'api/v1/system/status'
    
    def books(self):
        self.application = 'books'
        self.application_port = 8787
        self.apikey=open(f'/talecaster/shared/{self.application}.api').read()
        self.healthcheck = 'api/v1/system/status'

    def comics(self):
        self.application = 'comics'
        self.application_port = 8090
        self.apikey=open(f'/talecaster/shared/{self.application}.api').read()
        self.healthcheck = f'comics/api/?cmd=getVersion&apikey={self.apikey}'

def main(args):
    tgt=Application()
    tgt.indirect(args.application)
    headers = {
        'Content-type': 'application/json',
        'User-Agent': 'rootwyrm/talecaster',
        'X-Api-Key': str(tgt.apikey)
    }
    target = f'http://{tgt.application}/{tgt.application_port}/{tgt.application}/{tgt.healthcheck}'
    response = requests.get(target, headers=header)
    if response.status_code == 200:
        print('OK')
    else:
        print('Not Healthy')

parser = ArgumentParser(description="TaleCaster Health Checker")
parser.add_argument("-a", "--app", dest="application", type=str, help="Application to check", required=True)
args = parser.parse_args()
main(args)
