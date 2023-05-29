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
import ipaddress 
import random
import re
import fileinput
from argparse import ArgumentParser
from rich import print
## sqlite3 and psycopg2 go in respective functions.

class Application(object):
    def indirect(self,application):
        method_name=application
        method=getattr(self,method_name,lambda :'Invalid')
        return method()

    def television(self):
        self.application = 'television'
        self.application_port = 8989
        self.application_sslport = 8990
        self.implementation = 'Sonarr'
        self.implementationName = 'Sonarr'
        self.configContract = 'SonarrSettings'
        self.apiKeyType = 'uuid'

    def movies(self):
        self.application = 'movies'
        self.application_port = 7878
        self.application_sslport = 7879
        self.implementation = 'Radarr'
        self.implementationName = 'Radarr'
        self.configContract = 'RadarrSettings'
        self.apiKeyType = 'uuid'

    def music(self):
        self.application = 'music'
        self.application_port = 8686
        self.application_sslport = 8687
        self.implementation = 'Lidarr'
        self.implementationName = 'Lidarr'
        self.configContract = 'LidarrSettings'
        self.apiKeyType = 'uuid'

    def books(self):
        self.application = 'books'
        self.application_port = 8787
        self.application_sslport = 8788
        self.implementation = 'Readarr'
        self.implementationName = 'Readarr'
        self.configContract = 'ReadarrSettings'
        self.apiKeyType = 'uuid'

    def comics(self):
        self.application = 'comics'
        self.application_port = 8090
        self.application_sslport = 8091
        self.implementation = 'Mylar'
        self.implementationName = 'Mylar'
        self.configContract = 'MylarSettings'
        self.apiKeyType = 'pythongen'

    def indexer(self):
        self.application = 'indexer'
        self.application_port = 9696
        self.application_sslport = 9697
        self.implementation = 'Prowlarr'
        self.implementationName = 'Prowlarr'
        self.configContract = 'ProwlarrSettings'
        self.apiKeyType = 'uuid'

    def nntp(self):
        self.application = 'nntp'
        self.application_port = 6789
        self.application_sslport = 6790
        self.implementation = 'SABnzbd'
        self.implementationName = 'SABnzbd'
        self.configContract = 'SABnzbd'
        self.apiKeyType = 'pythongen'
    
    def torrent(self):
        self.application = 'torrent'
        self.application_port = 8081
        self.application_sslport = 8082
        self.implementation = 'qBittorrent'
        self.implementationName = 'qBittorrent'
        self.configContract = 'qBittorrentSettings'

def __main__():
    global log_prefix
    global this_application
    log_prefix = "[[bold dark_blue]TaleCaster[/]]"
    this_application = open('/opt/talecaster/id.provides', 'r').read()
    ## Strip newline internally; required by external pieces
    this_application = this_application.replace('\n','')

    global service
    service=Application()
    service.indirect(this_application)

    print("service", service.application)
    match service.application:
        case "indexer" | "movies" | "television" | "music" | "xxx":
            ## Only for Sonarr v4
            configure_servarr(this_application)
        case "nntp":
            configure_sabnzbd()
        case "torrent":
            configure_qbittorrent()    
        case default:
            ## Fall-through; unknown application
            print(log_prefix, "[bold red]FATAL[/]: Unknown application", service.application)
            os._exit(2) 

def configure_servarr(this_application):
    config_xml = '/talecaster/config/config.xml'

    match service.application:
        ## These do not support PostgreSQL backend
        case "indexer":
            if "POSTGRESQL_HOST" in os.environ:
                pg_host = os.environ["POSTGRESQL_HOST"]
            else:
                pg_host = None
            if "POSTGRESQL_USER" in os.environ:
                pg_user = os.environ["POSTGRESQL_USER"]
            else:
                pg_user = None
            if "POSTGRESQL_PASS" in os.environ:
                pg_pass = os.environ["POSTGRESQL_PASS"]
            else:
                pg_pass = None
            if "POSTGRESQL_PORT" in os.environ:
                pg_port = os.environ["POSTGRESQL_PORT"]
            else:
                pg_port = "5432"
            ## Test connection
            try:
                pg_maindb = "prowlarr"
                pg_logdb = "prowlarrlog"
                for db in [pg_maindb, pg_logdb]:
                    talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass, db)
            except:
                print(log_prefix, "[bold red]FATAL[/]: configuration invalid, aborting!")
                os._exit(100)

            print(log_prefix, "Using PostgreSQL server at", pg_host, "with user", pg_user)
        case "music":
            if "POSTGRESQL_HOST" in os.environ:
                pg_host = os.environ["POSTGRESQL_HOST"]
            else:
                pg_host = None
            if "POSTGRESQL_USER" in os.environ:
                pg_user = os.environ["POSTGRESQL_USER"]
            else:
                pg_user = None
            if "POSTGRESQL_PASS" in os.environ:
                pg_pass = os.environ["POSTGRESQL_PASS"]
            else:
                pg_pass = None
            if "POSTGRESQL_PORT" in os.environ:
                pg_port = os.environ["POSTGRESQL_PORT"]
            else:
                pg_port = "5432"
            ## Test connection
            try:
                pg_maindb = "lidarr"
                pg_logdb = "lidarrlog"
                for db in [pg_maindb, pg_logdb]:
                    talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass, db)
            except:
                print(log_prefix, "[bold red]FATAL[/]: configuration invalid, aborting!")
                os._exit(100)
        case "movies":
            if "POSTGRESQL_HOST" in os.environ:
                pg_host = os.environ["POSTGRESQL_HOST"]
            else:
                pg_host = None
            if "POSTGRESQL_USER" in os.environ:
                pg_user = os.environ["POSTGRESQL_USER"]
            else:
                pg_user = None
            if "POSTGRESQL_PASS" in os.environ:
                pg_pass = os.environ["POSTGRESQL_PASS"]
            else:
                pg_pass = None
            if "POSTGRESQL_PORT" in os.environ:
                pg_port = os.environ["POSTGRESQL_PORT"]
            else:
                pg_port = "5432"
            ## Test connection
            try:
                pg_maindb = "radarr"
                pg_logdb = "radarrlog"
                for db in [pg_maindb, pg_logdb]:
                    talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass, db)
            except:
                print(log_prefix, "[bold red]FATAL[/]: configuration invalid, aborting!")
                os._exit(100)
        case "books":
            if "POSTGRESQL_HOST" in os.environ:
                pg_host = os.environ["POSTGRESQL_HOST"]
            else:
                pg_host = None
            if "POSTGRESQL_USER" in os.environ:
                pg_user = os.environ["POSTGRESQL_USER"]
            else:
                pg_user = None
            if "POSTGRESQL_PASS" in os.environ:
                pg_pass = os.environ["POSTGRESQL_PASS"]
            else:
                pg_pass = None
            if "POSTGRESQL_PORT" in os.environ:
                pg_port = os.environ["POSTGRESQL_PORT"]
            else:
                pg_port = "5432"
            ## Test connection
            try:
                pg_maindb = "readarr"
                pg_logdb = "readarrlog"
                pg_cachedb = "readarrcache"
                for db in [pg_maindb, pg_logdb, pg_cachedb]:
                    talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass, db)
            except:
                print(log_prefix, "[bold red]FATAL[/]: configuration invalid, aborting!")
                os._exit(100)

        case default:
            print(log_prefix, service.implementation, "does not support PostgreSQL, ignoring.")
            pg_host = None
            pg_user = None
            pg_pass = None
            pg_port = None

    try:
        os.path.isfile(config_xml)
        print(log_prefix, "Found existing configuration, updating.")
        ## Store the existing API key
        apikeyfile = open(f'/talecaster/shared/{service.application}.api', 'r')
        apikey = apikeyfile.read()
        print(log_prefix, "Reusing existing API key", apikey)
        ## Always close because we will be opening for write.
        apikeyfile.close()
        config_exists = True
    except:
        print(log_prefix, "[bold dark_red]ERROR:[/] Unable to locate API key, generating new configuration.")
        ch = open(config_xml, 'w')
        ch.write('')
        ch.close()
        apikey = generate_apikey(service.apiKeyType)

    ## Now write the file.
    acf = open(config_xml, 'w')
    acf.write("<Config>\n")
    acf.write("  <LogLevel>info</LogLevel>\n")
    acf.write("  <UpdateMechanism>BuiltIn</UpdateMechanism>\n")
    acf.write("  <BindAddress>*</BindAddress>\n")
    acf.write(f"  <Port>{service.application_port}</Port>\n")
    acf.write(f"  <SslPort>{service.application_sslport}</SslPort>\n")
    acf.write(f"  <UrlBase>/{service.application}</UrlBase>\n")
    acf.write(f"  <ApiKey>{apikey}</ApiKey>\n")
    #acf.write("  <AuthenticationMethod>External</AuthenticationMethod>\n")
    acf.write("  <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>\n")
    acf.write("  <LaunchBrowser>False</LaunchBrowser>\n")
    acf.write("  <Branch>master</Branch>\n")
    acf.write(f"  <InstanceName>{service.implementation}</InstanceName>\n")
    ## Really should only expect to see this in k8s clusters, which we don't support unless it's FCoE
    ## XXX: ENABLE_SSL is for nginx only; k8s users will need to fuss with ENABLE_SSL_$APPLICATION
    if f"ENABLE_SSL_{str.upper(service.application)}" in os.environ:
        acf.write("  <EnableSsl>True</EnableSsl>\n")
        acf.write("  <SslCertPath>", os.environ["SSL_CERT"], "</SslCertPath>\n")
        acf.write("  <SslCertPassword>", os.environ["SSL_PASSWORD"], "</SslCertPassword>\n")
    else:
        acf.write("  <EnableSsl>False</EnableSsl>\n")
    if pg_host is not None:
        ## Write the psqlrc since scripts that run as talecaster need to connect to the database.
        acf.write(f"  <PostgresUser>{pg_user}</PostgresUser>\n")
        acf.write(f"  <PostgresPassword>{pg_pass}</PostgresPassword>\n")
        acf.write(f"  <PostgresHost>{pg_host}</PostgresHost>\n")
        acf.write(f"  <PostgresPort>{pg_port}</PostgresPort>\n")
        acf.write(f"  <PostgresMainDb>{pg_maindb}</PostgresMainDb>\n")
        acf.write(f"  <PostgresLogDb>{pg_logdb}</PostgresLogDb>\n")
        if service.application == "Readarr":
            acf.write(f"  <PostgresCacheDb>{pg_cachedb}</PostgresCacheDb>\n")
        talecaster_pgpass(pg_host, pg_user, pg_pass, pg_port, "Prowlarr")
        talecaster_pgpass(pg_host, pg_user, pg_pass, pg_port, "ProwlarrLog")
    acf.write("</Config>")
    print(log_prefix, "New configuration generated.")
    acf.close()
    os.chown('/talecaster/config/config.xml', int(os.environ["tcuid"]), int(os.environ["tcgid"]))

    ## NYI - need to think on it more
    def replace_element(element, value):
        for line in fileinput.input(config_xml, inplace=True):
            line.replace(".*{element}.*","  <{element}>{value}</{element}>")

def generate_apikey(type):
    match type:
        case "uuid":
            import uuid
            apikey = str(uuid.uuid4())
            apikey = apikey.replace('-','') 
            return(apikey)
        case "python":
            ## Copy-paste from SABnzbd to maintain compatibility
            import uuid
            apikey = uuid.uuid4().hex
            return(apikey)
        case default:
            print(log_prefix, "[bold red]FATAL[/]: generate_apikey received invalid key type to generate!")
            ## Unhandled error
            os._exit(10)

def talecaster_psqlrc():
    psqlrc = open('/home/talecaster/.psqlrc', 'w')
    ## Set the defaults that I prefer
    psqlrc.write("\set COMP_KEYWORD_CASE upper\n")
    psqlrc.write("\set ON_ERROR_ROLLBACK interactive\n")
    psqlrc.write("\pset null '(null)'\n")
    psqlrc.write("\pset pager off\n")
    psqlrc.write("\set PROMPT1 '[TaleCaster]\n%m:%> %x\n%n@%/ %R%# '\n")
    psqlrc.write("\set PROMPT2 '[TaleCaster]\n%w%R%# '\n")

def talecaster_pgpass(pg_host, pg_user, pg_pass, pg_port, database):
    try:
        pgpass = open('/home/talecaster/.pgpass', 'a')
        pgpass.write(f'{pg_host}:{pg_port}:{database}:{pg_user}:{pg_pass}\n')
        os.chown('/home/talecaster/.pgpass', int(os.environ["tcuid"]), int(os.environ["tcgid"]))
        os.chmod('/home/talecaster/.pgpass', 0o0600)
    except:
        print(log_prefix, "[bold red]FATAL[/]: could not write to /home/talecaster/.pgpass")

def talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass, database):
    ## Attempt to connect to the provided PostgreSQL database
    import psycopg2
    ## Convert host to str so IP works, and password so that unescaped characters work
    if database is None:
        database = 'template1'

    try:
        dbconn = psycopg2.connect(host=str(pg_host), port=int(pg_port), user=str(pg_user), password=str(pg_pass), dbname=str(database))
        print(log_prefix, "Validating connection to", database, "with", pg_user + "@" + pg_host)
        dbconn
        dbconn.close()
    except psycopg2.Error as e:
        print(log_prefix, "[bold red]FATAL[/]: connection to", database, "failed!", e)
        raise e

def talecaster_pgconnsutest(pg_host, pg_port, pg_user, pg_pass):
    ## Tests if superuser account is working
    ## XXX: not yet used; part of setup process to create databases
    import psycopg2
    dbconn = psycopg2.connect(host=str(pg_host), port=int(pg_port), user=str(pg_user), password=str(pg_pass), dbname='template1')
    try:
        print(log_prefix, "Validating database superuser connection to", pg_host)
        dbconn
        ## NOTE: might be an easier way to implement this, but prefer this for version interop for the time being
        query = f"SELECT rolname FROM pg_roles WHERE rolname='{pg_user}' AND rolsuper='t'"
        cur = dbconn.cursor()
        cur.execute(query)
        cur.close()
    except:
        print(log_prefix, "[bold red]FATAL[/]: superuser connection failed to validate.")
        raise ConnectionError

def configure_sabnzbd():
    ## This one's a real nightmare, because SABnzbd uses a rather complicated INI
    import configparser
    import shutil
    baseconfig = '/opt/talecaster/defaults/sabnzbd.base.ini'
    categories = '/opt/talecaster/defaults/sabnzbd.categories.ini'
    inifile = '/talecaster/config/sabnzbd.ini'
    try:
        open(inifile, 'r')
        print(log_prefix, "Backing up and updating SABnzbd configuration")
        shutil.copyfileobj(inifile, inifile + '.bak')
    except:
        print(log_prefix, "SABnzbd configuration not found, generating new configuration")

    runconfig = open(inifile, 'w')
    liveconfig = configparser.ConfigParser()
    liveconfig.read(baseconfig)

    ## Calculate cache as 10% of system memory - especially important if PostgreSQL is on the same host
    cache_limit = int(os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES') * 0.10)
    ## Display as megabytes for readability
    cache_limit = int(cache_limit / 1024 / 1024)
    cache_limit = str(cache_limit) + 'M'
    print(log_prefix, "Calculated cache limit as", cache_limit)

    ## Set cache_limit
    liveconfig['misc']['cache_limit'] = cache_limit

    ## Set API key
    if os.path.exists('/talecaster/shared/nntp.api'):
        api_key = open('/talecaster/shared/nntp.api', 'r').read()
        print(log_prefix, "Reusing existing API key", api_key)
        liveconfig['misc']['api_key'] = api_key
    else:
        api_key = generate_apikey('python')
        print(log_prefix, "Generated new API key", api_key)
        liveconfig['misc']['api_key'] = api_key
    ## Set NZB key
    if os.path.exists('/talecaster/shared/nntp_nzb.api'):
        nzb_key = open('/talecaster/shared/nntp_nzb.api', 'r').read()
        print(log_prefix, "Reusing existing NZB key", nzb_key)
        liveconfig['misc']['nzb_key'] = nzb_key 
    else:
        nzb_key = generate_apikey('python')
        print(log_prefix, "Generated new NZB key", nzb_key)
        liveconfig['misc']['nzb_key'] = nzb_key

    if "NNTP_USER" and "NNTP_PASSWORD" in os.environ:
        liveconfig['misc']['username'] = os.environ['NNTP_USER']
        liveconfig['misc']['password'] = os.environ['NNTP_PASSWORD']
    else:
        liveconfig['misc']['username'] = ''
        liveconfig['misc']['password'] = ''

    ## SOCKS5 settings
    if "SOCKS5_PROXY" in os.environ:
        liveconfig['misc']['socks5_proxy_url'] = "socks5://" + os.environ["SOCKS5_PROXY"]
    else:
        liveconfig['misc']['socks5_proxy_url'] = ''
    if "SOCKS5_USER" in os.environ:
        liveconfig['misc']['socks5_proxy_url'] = "socks5://" + {os.environ["SOCKS5_USER"]} + "@" + {os.environ["SOCKS5_PROXY"]}
    elif "SOCKS5_PASSWORD" and "SOCKS5_USER" in os.environ:
        liveconfig['misc']['socks5_proxy_url'] = "socks5://" + {os.environ["SOCKS5_USER"]} + ":" + {os.environ["SOCKS5_PASSWORD"]} + "@" + {os.environ["SOCKS5_PROXY"]}
    if "SOCKS5_PORT" in os.environ:
        liveconfig['misc']['socks5_proxy_url'] = liveconfig['misc']['socks5_proxy_url'] + ":" + os.environ["SOCKS5_PORT"]


    ## Use local subnet on eth0; don't iterate. Then VPN will be included.
    import netifaces
    from ipaddress import IPv4Network
    ipaddr = netifaces.ifaddresses('eth0')[netifaces.AF_INET][0]['addr']
    netmask = netifaces.ifaddresses('eth0')[netifaces.AF_INET][0]['netmask']
    netmask = IPv4Network(f'{ipaddr}/{netmask}', strict=False).prefixlen
    subnet = f'{ipaddr}/{netmask}'
    liveconfig['misc']['local_ranges'] = '127.0.0.0/8,' + subnet

    ## Write out inifile from liveconfig
    runconfig.write("__version__ = 19\n")
    runconfig.write("__encoding__ = utf-8\n")
    liveconfig.write(runconfig)
    catini = open(categories, 'r')
    runconfig.write(catini.read())
    os.chown(inifile, int(os.environ["tcuid"]), int(os.environ["tcgid"]))

    ## Now configure the servers section from /etc/sabnzbd.servers.ini
    ## XXX: should test for /talecaster/config/servers.ini and merge that in first
    serverconfig = configparser.ConfigParser()
    #serverconfig.read('/opt/talecaster/defaults/sabnzbd.servers.ini')
    ## TODO: add support for multiple servers, maybe as yaml?
    if "NNTP_SERVER" in os.environ:
        print(log_prefix, "Adding server", os.environ["NNTP_SERVER"])
        serverid = f'[{os.environ["NNTP_SERVER"]}]'
        from pprint import pprint
        pprint(serverid)
        serverconfig.add_section(serverid)
        pprint(serverconfig.sections())
        serverconfig.setdefault(serverid, {})
        serverconfig.set(serverid, 'name', os.environ["NNTP_SERVER"])
        serverconfig.set(serverid, 'displayname', os.environ["NNTP_SERVER"])
        serverconfig.set(serverid, 'host', os.environ['NNTP_SERVER'])
        if "NNTP_SERVER_PORT" in os.environ:
            serverconfig.set(serverid, 'port', os.environ['NNTP_SERVER_PORT'])
        else:
            serverconfig.set(serverid, 'port', '563')
        serverconfig.set(serverid, 'connections', '10')
        if "NNTP_SERVER_LIMIT" in os.environ:
            serverconfig.set(serverid, 'connections', os.environ['NNTP_SERVER_LIMIT'])
        else:
            serverconfig.set(serverid, 'connections', '10')
        serverconfig.set(serverid, 'ssl', '1')
        serverconfig.set(serverid, 'ssl_verify', '2')
        serverconfig.set(serverid, 'username', os.environ['NNTP_SERVER_USER'])
        serverconfig.set(serverid, 'password', os.environ['NNTP_SERVER_PASSWORD'])
        runconfig.write('[servers]\n')
        serverconfig.write(runconfig)
    elif os.path.exists('/talecaster/config/servers.ini'):
        print(log_prefix, "Found /talecaster/config/servers.ini - merging configuration")
        servers = open('/talecaster/config/servers.ini', 'r')
        runconfig.write(servers.read())
    else:
        ## Use a non-functional default to prevent the wizard
        print(log_prefix, "[bold dark_orange]WARNING:[/] No NNTP_SERVER defined - configure in the web interface.")
        servers = open('/opt/talecaster/defaults/sabnzbd.server.ini', 'r')
        runconfig.write(servers.read())

    ############################################################
    ## Debug section
    ############################################################
    #os.system('cat /tmp/sabnzbd.ini')

def configure_qbittorrent():
    ## XXX: qbittorrent doesn't provide any sort of APIkey method still
    if "TORRENT_USER" in os.environ:
        qbt_user = os.environ["TORRENT_USER"]
    else:
        print(log_prefix, "[bold dark_red]FATAL:[/] must provide a TORRENT_USER!")
        sys.exit(1)
    if "TORRENT_PASSWORD" in os.environ:
        qbt_pass = os.environ["TORRENT_PASSWORD"]
    else:
        print(log_prefix, "[bold dark_red]FATAL:[/] must provide a TORRENT_PASSWORD!")
        sys.exit(1)

    import configparser
    import netifaces
    ## Make configParser object with case sensitivity
    runconfig = configparser.ConfigParser()
    runconfig.optionxform = str
    runconfig.allow_no_value = False
    ## NOTE: the defaults in /opt/talecaster/defaults/qBittorrent.conf are only
    ## minimums.
    
    ## TODO: Wireguard and ZeroTier
    if "TORRENT_VPN_CONFIG" in os.environ:
        vpn = True
    else:
        vpn = False

    defaults = open('/opt/talecaster/defaults/qBittorrent.conf', encoding='utf-8')
    runconfig.read_file(defaults)

    if os.path.isfile('/talecaster/config/qBittorrent/config/qBittorrent.conf') is True:
        ## Bail if the config file is empty
        if os.stat('/talecaster/config/qBittorrent/config/qBittorrent.conf').st_size == 0:
            print(log_prefix, "Existing configuration is empty, using defaults")
            return
        else:
            print(log_prefix, "Found existing configuration, merging")
            runconfig.read_file('/talecaster/config/qBittorrent/config/qBittorrent.conf')
    else: 
        print(log_prefix, "No existing configuration found, using defaults")

    ## portrange must be above 10000 since TaleCaster ports run up to 9999
    portrange = random.randint(10000,60000)

    ## Critical for autostart
    if runconfig.has_section('LegalNotice') is False:
        runconfig.add_section('LegalNotice')
    runconfig['LegalNotice']['Accepted'] = 'true'

    ## Torrent tuning pieces
    if runconfig.has_section('BitTorrent') is False:
        runconfig.add_section('BitTorrent')
    runconfig['BitTorrent']['Session\\Port'] = str(portrange)
    runconfig['BitTorrent']['Session\\QueueingSystemEnabled'] = 'true'

    if runconfig.has_section('Core') is False:
        runconfig.add_section('Core')
    runconfig.set('Core', 'AutoDeleteAddedTorrentFile', 'IfAdded')

    if runconfig.has_section('Network') is False:
        runconfig.add_section('Network')
    runconfig['Network']['Cookies'] = '@Invalid()'

    ## Preferences
    if runconfig.has_section('Preferences') is False:
        runconfig.add_section('Preferences')
    runconfig.set('Preferences', 'Advanced\\RecheckOnCompletion', 'false')
    runconfig.set('Preferences', 'Advanced\\ResolvePeerCountries', 'true')
    ## Connection settings
    runconfig.set('Preferences', 'Connection\\PortRangeMin', str(portrange))
    runconfig.set('Preferences', 'Connection\\ResolvePeerCountries', 'true')
    runconfig.set('Preferences', 'Connection\\UseIncompleteExtension', 'true')
    ## Download settings
    runconfig.set('Preferences', 'Downloads\\SavePath', '/talecaster/downloads')
    runconfig.set('Preferences', 'Downloads\\IncompleteExtensions', 'true')

    ## WebUI
    runconfig['Preferences']['WebUI\\BanDuration'] = '3600'
    runconfig['Preferences']['WebUI\\LocalHostAuth'] = 'false'
    runconfig['Preferences']['WebUI\\Port'] = '9091'
    ## XXX: UseUPnP doesn't work without host networking
    runconfig['Preferences']['WebUI\\UseUPnP'] = 'false'
    runconfig['Preferences']['Queueing\\QueueingEnabled'] = 'true'

    ## Whitelisting
    whitelist = []
    whitelist.append("127.0.0.0/8")
    ## Use netifaces-plus to get the network and subnet mask
    local_addr = netifaces.ifaddresses('eth0')[netifaces.AF_INET][0]['addr']
    local_mask = netifaces.ifaddresses('eth0')[netifaces.AF_INET][0]['netmask']
    local_net = ipaddress.IPv4Network(f'{local_addr}/{local_mask}', strict=False)
    whitelist.append(str(local_net))
    whitelist = str(','.join(whitelist))
    runconfig['Preferences']['WebUI\\AuthSubnetWhitelistEnabled'] = 'true'
    runconfig['Preferences']['WebUI\\AuthSubnetWhitelist'] = f"{whitelist}"

    ## Username and password 
    ## Convert plaintext password to PBKDF2
    qbt_pass = qbittorrent_password(os.environ["TORRENT_PASSWORD"])
    runconfig['Preferences']['WebUI\\Username'] = qbt_user
    runconfig['Preferences']['WebUI\\Password_PBKDF2'] = qbt_pass

    ## Set language since qBittorrent has translations
    if "LANGUAGE" in os.environ:
        runconfig.set('Preferences', 'General\\Locale', os.environ["LANGUAGE"])

    ## TODO: Wireguard 
    if vpn is True:
        try:
            interface = netifaces.interfaces('tun0')
        except interface.DoesNotExist:
            print(log_prefix, "unable to open tun0 interface, bailing out!")
            sys.exit(10)
        if runconfig.has_section('BitTorrent') is False:
            runconfig.add_section('BitTorrent')
        runconfig['BitTorrent']['Session\\Interface'] = 'tun0'
        runconfig['BitTorrent']['Session\\InterfaceName'] = 'tun0'
        ## Limit to IPv4 only
        runconfig['BitTorrent']['Session\\InterfaceAddress'] = '0.0.0.0'

    ## XXX: SOCKS5 proxy goes here, NYI
    ## SOCKS5 settings
    #if "SOCKS5_PROXY" in os.environ:
    #    runconfig['Network']['ProxyType'] = 'SOCKS5'
    #    runconfig['Network']['Proxy\\Type'] = 'SOCKS5'
    #    ## qBittorrent only uses IP address here
    #    import socket
    #    socks5_ip = socket.gethostbyname(os.environ["SOCKS5_PROXY"])
    #    runconfig['Network']['IP'] = socks5_ip[0]
    #if "SOCKS5_PORT" in os.environ:
    ## XXX: This function doesn't work as intended.
    #    ## This is an '@Variant' type, so we need to convert it
    #    ## PyQt5's 400MB+ can bite me.
    #    ## https://gitlab.com/TC01/quasselconf/-/tree/master/quasselconf - for reference if we do use pyqt
    #    port_int = int(os.environ["SOCKS5_PORT"])
    #    port_bytes = struct.pack("<i", port_int)
    #    port_bytes = b"@Variant(\0\0\0" + port_bytes + b"\x1f\x90)"
    #    port_str = port_bytes.decode('latin-1')
    #    port_str_printable = re.sub(r'[^\x20-\x7E]', '', port_str)
    #    #print(port_str_printable.decode('utf-8'))
    #    runconfig['Network']['Port'] = port_str_printable
    ## CAUTION: these are stored in plaintext in the config, even if we use secrets
    #if "SOCKS5_USER" in os.environ:
    #    runconfig['Network']['Proxy\\Username'] = os.environ["SOCKS5_USER"]
    #elif "SOCKS5_PASSWORD" and "SOCKS5_USER" in os.environ:
    #    runconfig['Network']['Proxy\\Password'] = os.environ["SOCKS5_PASSWORD"]
    

    ## Test if /talecaster/convig/qBittorrent/config exists
    if os.path.exists('/talecaster/config/qBittorrent') is False:
        os.makedirs('/talecaster/config/qBittorrent')
        os.chown('/talecaster/config/qBittorrent', int(os.environ["tcuid"]), int(os.environ["tcgid"]))
    if os.path.exists('/talecaster/config/qBittorrent/config') is False:
        os.makedirs('/talecaster/config/qBittorrent/config')
        os.chown('/talecaster/config/qBittorrent/config', int(os.environ["tcuid"]), int(os.environ["tcgid"]))

    conf = open('/talecaster/config/qBittorrent/config/qBittorrent.conf', 'w')
    try:
        print(log_prefix, "Writing qBittorrent.conf")
        runconfig.write(conf)
    except:
        print(log_prefix, '[bold dark_red]FATAL:[/] Error writing config file!', conf.errors)
        os._exit(2)
    finally:
        conf.close()
    
    ## Copy the json files from defaults to /talceaster/config/qBittorrent/config
    import shutil
    shutil.copyfile('/opt/talecaster/defaults/watched_folders.json', '/talecaster/config/qBittorrent/config/watched_folders.json')
    shutil.copyfile('/opt/talecaster/defaults/categories.json', '/talecaster/config/qBittorrent/config/categories.json')
    os.chown('/talecaster/config/qBittorrent/config/watched_folders.json', int(os.environ["tcuid"]), int(os.environ["tcgid"]))
    os.chown('/talecaster/config/qBittorrent/config/categories.json', int(os.environ["tcuid"]), int(os.environ["tcgid"]))

def qbittorrent_password(password):
    """
    This is the function in qBittorrent 
    QByteArray Utils::Password::PBKDF2::generate(const QByteArray &password)
    {
        const std::array<uint32_t, 4> salt
        {{Random::rand(), Random::rand()
            , Random::rand(), Random::rand()}};

        std::array<unsigned char, 64> outBuf {};
        const int hmacResult = PKCS5_PBKDF2_HMAC(password.constData(), password.size()
            , reinterpret_cast<const unsigned char *>(salt.data()), static_cast<int>(sizeof(salt[0]) * salt.size())
            , hashIterations, hashMethod
            , static_cast<int>(outBuf.size()), outBuf.data());
        if (hmacResult != 1)
            return {};

        const QByteArray saltView = QByteArray::fromRawData(
            reinterpret_cast<const char *>(salt.data()), static_cast<int>(sizeof(salt[0]) * salt.size()));
        const QByteArray outBufView = QByteArray::fromRawData(
            reinterpret_cast<const char *>(outBuf.data()), static_cast<int>(outBuf.size()));

        return (saltView.toBase64() + ':' + outBufView.toBase64());
    }
    """
    import hashlib  
    import binascii
    import base64
    salt = binascii.hexlify(os.urandom(32))
    hashed = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, 100000)
    hashed = binascii.hexlify(hashed)
    ## Now convert the hashed password and salt into base64
    hashed = base64.b64encode(hashed)
    salt = base64.b64encode(salt)
    ## Strip the :b from the base64 encoding
    return f"@ByteArray({hashed.decode('utf-8')}:{salt.decode('utf-8')})"


__main__()