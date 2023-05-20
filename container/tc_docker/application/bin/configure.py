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
            print("nntp testing only")
            configure_sabnzbd()
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
                talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass)
                pg_maindb = "prowlarr"
                pg_logdb = "prowlarrlog"
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
                talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass)
                pg_maindb = "lidarr"
                pg_logdb = "lidarrlog"
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
                talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass)
                pg_maindb = "radarr"
                pg_logdb = "radarrlog"
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
                talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass)
                pg_maindb = "readarr"
                pg_logdb = "readarrlog"
                pg_cachedb = "readarrcache"
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
        acf.write("  <SslCertPath>", os.environ["SSL_CERT"].read(), "</SslCertPath>\n")
        acf.write("  <SslCertPassword>", os.environ["SSL_PASSWORD"].read(), "</SslCertPassword>\n")
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

def talecaster_pgconntest(pg_host, pg_port, pg_user, pg_pass):
    ## Attempt to connect to the provided PostgreSQL database
    import psycopg2
    ## Convert host to str so IP works, and password so that unescaped characters work
    dbconn = psycopg2.connect(host=str(pg_host), port=int(pg_port), user=str(pg_user), password=str(pg_pass), dbname='template1')
    try:
        print(log_prefix, "Validating database connection to", pg_host)
        dbconn
        dbconn.close()
    except:
        raise ConnectionError

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

__main__()