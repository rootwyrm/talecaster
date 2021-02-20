#!/usr/bin/env python3
################################################################################
# TaleCaster
# Copyright (C) 2015-* Phillip R. Jaenke <talecaster@rootwyrm.com> and its
# contributors. All rights reserved
# 
# Licensed under CC-BY-NC-4.0
# See /LICENSE for details
################################################################################

import os
import sys
import time
import datetime
from dateutil import tz
import configparser

class icalModule(object):
    def __init__(self):
        self.timezone = time.tzname[0]
        self.inifile = "/opt/talecaster/html/aggregate.ini"
        self.config = configparser.ConfigParser()

    def ical_ini_core(self):
        self.inifile = open('/opt/talecaster/html/aggregate.ini', 'w')
        if not self.config.has_section("core"):
            self.config.add_section("core")
            self.config.set("core", "timezone", self.timezone)
            # XXX: do NOT set an hour offset!
        with self.inifile as configfile:
            self.config.write(self.inifile)
    def ical_ini_files(self):
        self.inifile = open('/opt/talecaster/html/aggregate.ini', 'w')
        if not self.config.has_section("files"):
            self.config.add_section("files")
            self.config.set("files", "ical", "aggregate.ics")
            self.config.set("files", "html", "calendar.html")
        with self.inifile as configfile:
            self.config.write(self.inifile)

    ## These functions are hard-coded this way for a *reason*.
    ## It only works with Sonarr/Radarr/Lidarr to make an aggregate.
    ## And it depends on updating the API *every* time the containers
    ## are rebuilt or the API is regenerated. Without the API key, the
    ## calendar doesn't work, simple as that.
    def ical_ini_sonarr(self):
        # Sonarr
        with open("/talecaster/shared/sonarr.api", "r") as apik:
            apikey = apik.readline()
        self.inifile = open('/opt/talecaster/html/aggregate.ini', 'w')
        if not self.config.has_section("rooms"):
            self.config.add_section("rooms")
            self.config.set("rooms", "television", f"http://172.16.100.30/television/feed/calendar/Sonarr.ics?apikey={apikey}")
        elif self.config.has_section("rooms"):
            ## Always set it, because the API regenerates.
            self.config.set("rooms", "television", f"http://172.16.100.30/television/feed/calendar/Sonarr.ics?apikey={apikey}")
        with self.inifile as configfile:
            self.config.write(self.inifile)
    def ical_ini_radarr(self):
        # Radarr
        with open("/talecaster/shared/radarr.api", "r") as apik:
            apikey = apik.readline()
        self.inifile = open('/opt/talecaster/html/aggregate.ini', 'w')
        if not self.config.has_section("rooms"):
            self.config.add_section("rooms")
            self.config.set("rooms", "movies", f"http://172.16.100.31/movies/feed/calendar/Radarr.ics?apikey={apikey}")
        elif self.config.has_section("rooms"):
            ## Always set it, because the API regenerates.
            self.config.set("rooms", "movies", f"http://172.16.100.31/movies/feed/calendar/Radarr.ics?apikey={apikey}")
        with self.inifile as configfile:
            self.config.write(self.inifile)
    def ical_ini_lidarr(self):
        # Radarr
        with open("/talecaster/shared/lidarr.api", "r") as apik:
            apikey = apik.readline()
        self.inifile = open('/opt/talecaster/html/aggregate.ini', 'w')
        if not self.config.has_section("rooms"):
            self.config.add_section("rooms")
            self.config.set("rooms", "music", f"http://172.16.100.32/music/feed/calendar/Lidarr.ics?apikey={apikey}")
        elif self.config.has_section("rooms"):
            ## Always set it, because the API regenerates.
            self.config.set("rooms", "music", f"http://172.16.100.32/music/feed/calendar/Lidarr.ics?apikey={apikey}")
        with self.inifile as configfile:
            self.config.write(self.inifile)

def read_api_key(apifile):
    """
    Need to pull the API keys out of /talecaster/shared for each calendar.
    """
    with open(apifile, 'r') as key:
        apikey = key.readlines()
    return apikey

def main():
    ical = icalModule()
    ical.ical_ini_core()
    ical.ical_ini_files()
    time_now = datetime.datetime.now()
    print(time_now)
    tzname = time.tzname[0]
    print(time_now.utcoffset())
    print(tz.gettz(tzname).utcoffset(datetime.datetime.utcnow()))
    ical.ical_ini_sonarr()
    ical.ical_ini_radarr()
    ical.ical_ini_lidarr()
    #for key in ["sonarr.api","radarr.api"]:
    #    keyresult = read_api_key(f"/talecaster/shared/{key}")
    #    print(keyresult)

main()
