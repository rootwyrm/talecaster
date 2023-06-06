## Definitions for our applications
import os
import psycopg2
import psycopg2.extras
import rich

global tc_prefix = "[bold cyan][TaleCaster][/]"
global error_prefix = "[bold red][ERROR][/]:"
global warning_prefix = "[bold dark_orange][WARNING][/]:"
global info_prefix = "[bold yellow][INFO][/]:"
global debug_prefix = "[bold blue][DEBUG][/]:"

class Application(object):
    def indirect(self,application):
        method_name=application
        method=getattr(self,method_name,lambda :'Invalid')
        return method()

    def frontend(self):
        self.application = 'frontend'
        self.application_port = 80
        self.application_sslport = 443
        self.implementation = 'nginx'
        self.implementationName = 'nginx'
        self.configContract = 'nginx'
        self.application.selftest = os.system('/usr/sbin/nginx -t -c /etc/nginx/nginx.conf')
        self.application.config = configure_nginx()
        
    def television(self):
        self.application = 'television'
        self.application_port = 8989
        self.application_sslport = 8990
        self.implementation = 'Sonarr'
        self.implementationName = 'Sonarr'
        self.configContract = 'SonarrSettings'
        self.apiKeyType = 'uuid'
        self.database.type = [ 'sqlite3' ]

    def movies(self):
        self.application = 'movies'
        self.application_port = 7878
        self.application_sslport = 7879
        self.implementation = 'Radarr'
        self.implementationName = 'Radarr'
        self.configContract = 'RadarrSettings'
        self.apiKeyType = 'uuid'
        self.database.type = [ 'sqlite3', 'postgresql' ]
        self.database.postgresql.main = 'radarr'
        self.database.postgresql.log = 'radarr_log'

    def music(self):
        self.application = 'music'
        self.application_port = 8686
        self.application_sslport = 8687
        self.implementation = 'Lidarr'
        self.implementationName = 'Lidarr'
        self.configContract = 'LidarrSettings'
        self.apiKeyType = 'uuid'
        self.database.type = [ 'sqlite3', 'postgresql' ]
        self.database.postgresql.main = 'lidarr'
        self.database.postgresql.log = 'lidarr_log'

    def books(self):
        self.application = 'books'
        self.application_port = 8787
        self.application_sslport = 8788
        self.implementation = 'Readarr'
        self.implementationName = 'Readarr'
        self.configContract = 'ReadarrSettings'
        self.apiKeyType = 'uuid'
        self.database.postgresql.main = 'readarr'
        self.database.postgresql.log = 'readarr_log'
        self.database.postgresql.cachedb = 'readarr_cache'

    def comics(self):
        self.application = 'comics'
        self.application_port = 8090
        self.application_sslport = 8091
        self.implementation = 'Mylar'
        self.implementationName = 'Mylar'
        self.configContract = 'MylarSettings'
        self.apiKeyType = 'python'

    def indexer(self):
        self.application = 'indexer'
        self.application_port = 9696
        self.application_sslport = 9697
        self.implementation = 'Prowlarr'
        self.implementationName = 'Prowlarr'
        self.configContract = 'ProwlarrSettings'
        self.apiKeyType = 'uuid'
        self.database.postgresql.main = 'prowlarr'
        self.database.postgresql.log = 'prowlarr_log'

    def nntp(self):
        self.application = 'nntp'
        self.application_port = 6789
        self.application_sslport = 6790
        self.implementation = 'SABnzbd'
        self.implementationName = 'SABnzbd'
        self.configContract = 'SABnzbd'
        self.apiKeyType = 'python'
    
    def torrent(self):
        self.application = 'torrent'
        self.application_port = 8081
        self.application_sslport = 8082
        self.implementation = 'qBittorrent'
        self.implementationName = 'qBittorrent'
        self.configContract = 'qBittorrentSettings'

    def frontend(self):
        self.application = 'frontend'
        self.implementation = 'nginx'
        self.implementationName = 'nginx'
        self.configContract = 'nginx'

## INFO: Call as: tc_pg_database_create(Application.database.postgresql.main), (Application.database.postgresql.log), (Application.database.postgresql.cachedb)
class tc_pg_database_create(database):
    def __init__(self, database, user, password, host, port):
        self.database = database
        self.superuser = os.read('/run/secrets/POSTGRES_SUPERUSER_USERNAME')
        self.superuserpassword = os.read('/run/secrets/POSTGRES_SUPERUSER_PASSWORD')
        self.user = os.read('/run/secrets/POSTGRES_USERNAME')
        self.userpassword = os.read('/run/secrets/POSTGRES_PASSWORD')
        self.host = os.environ["POSTGRESQL_HOST"]
        if os.environ["POSTGRESQL_PORT"] is not None:
            self.port = os.environ["POSTGRESQL_PORT"]
        else:
            self.port = 5432

    def create_db(self, database):
        conn = psycopg2.connect(dbname='template1', user=self.superuser, password=self.superuserpassword, host=self.host, port=self.port)
        conn.autocommit = True
        cur = conn.cursor()
        try: 
            cur.execute('CREATE DATABASE %s WITH OWNER %s' % self.database)
        except psycopg2.errors.DuplicateDatabase:
            rich.print(tc_prefix, "Database already exists, trying to set user.")
            try:
                cur.execute('ALTER DATABASE %s OWNER TO %s' % self.database, self.user)
            ## FYI:: doesn't have an error if you assign to the same owner.
            except psycopg2.Error as e:
                rich.print(tc_prefix, "Error: %s" % e.pgerror)
                os._exit(e)

        except psycopg2.Error as e:
            if e == '0P000':
                ## Role does not exist, try to create
                create_user()
            else:
                rich.print(tc_prefix, "Error: %s" % e.pgerror)
                os._exit(e)
        cur.close()
        conn.close()

    def create_user(self):
        conn = psycopg2.connect(dbname='template1', user=self.superuser, password=self.superuserpassword, host=self.host, port=self.port)
        conn.autocommit = True
        cur = conn.cursor()
        try:
            cur.execute('CREATE USER %s WITH PASSWORD %s' % self.user, self.userpassword)
        except psycopg2.errors.DuplicateObject:
            rich.print(tc_prefix, "User already exists, skipping")
            pass
        cur.close()
        conn.close()