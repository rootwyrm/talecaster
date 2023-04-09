import os
import sys
import subprocess
import threading
import rich

## TaleCasterApplication object
class TaleCasterApplication(object):
    def indirect(self,service):
        method_name=service
        method=getattr(self,method_name,lambda :'Invalid')
        return method()
   
    ## Only supports Sonarr
    def television(self):
        self.application = 'television'
        self.application_method = 'runtime'
        self.application_bin = '/opt/Sonarr/Sonarr.exe'
        self.application_args = [ f'-appdata={self.application_configdir}', f'-data={self.application_configdir}', '-nobrowser' ]
    ## Only supports Radarr
    def movies(self):
        self.application = 'movies'
        self.application_method = 'runtime'
        self.application_bin = '/opt/Radarr/Radarr.exe'
        self.application_args = [ f'-appdata={self.application_configdir}', f'-data={self.application_configdir}', '-nobrowser' ]
    ## Only supports Lidarr
    def music(self):
        self.application = 'music'
        self.application_method = 'runtime'
        self.application_bin = '/opt/Lidarr/Lidarr.exe'
        self.application_args = [ f'-appdata={self.application_configdir}', f'-data={self.application_configdir}', '-nobrowser' ]
    ## Only supports Readarr
    def books(self):
        self.application = 'books'
        self.application_method = 'runtime'
        self.application_bin = '/opt/Readarr/Readarr.exe'
        self.application_args = [ f'-appdata={self.application_configdir}', f'-data={self.application_configdir}', '-nobrowser' ]
    ## Only supports Mylar (python)
    def comics(self):
        self.application = 'comics'
        self.application_method = 'python'
        self.application_bin = '/opt/mylar/mylar.py'
        self.application_args = ''
        self.python_venv_use = True
        self.python_venv_dir = '/opt/talecaster/venv'
    ## Only supports Prowlarr
    def indexer(self):
        self.application = 'indexer'
        self.application_method = 'runtime'
        self.application_bin = '/opt/Prowlarr/Prowlarr'
        self.application_config = '/talecaster/config/config.xml'
        self.application_configdir = '/talecaster/config'
        self.application_pidfile = '/talecaster/config/prowlarr.pid'
        self.application_args = [ f'-appdata={self.application_configdir}', f'-data={self.application_configdir}', '-nobrowser' ]
    ## Uses nginx always
    def frontend(self):
        self.application = 'frontend'
        self.application_method = 'direct'
        self.application_bin = '/usr/sbin/nginx'
        self.application_config = '/etc/nginx/nginx.conf'
        self.application_args = [ f'-c {self.application_config}' ] 
        self.application_selftest = os.system(["", self.application_bin, self.application_args, '-t', '-q' ])

    def nntp(self):
        self.application = 'nntp'
        self.application_method = 'direct'
        self.application_bin = '/opt/nzbget/nzbget'
        self.application_config = '/talecaster/config/nzbget.conf'
        self.application_args = [ f"-c {self.application_config}" ]

    ## The torrent stuff is more complicated...
    def qbittorrent(self):
        self.application = 'torrent'
        self.application_method = 'direct'
        self.application_bin = '/usr/local/bin/qbittorrent-nox'
        self.application_configdir = '/talecaster/config'
        self.application_args = [ f'--profile={self.application_configdir}' ]

    ## XXX: Not Yet Implemented
    def transmission(self):
        self.application = 'torrent'
        self.application_real = 'transmission'
        self.application_method = 'direct'
        self.application_bin = '/usr/local/bin/transmission'
        self.application_configdir = '/talecaster/config'

    ## XXX: Not Yet Implemented
    ## need to set default UI to web before running
    ## --config /talecaster/config 
    def deluge(self):
        self.application = 'torrent'
        self.application_real = 'deluge'
        self.application_method = 'direct'
        self.application_bin = '/usr/local/bin/deluge'
        self.application_configdir = '/talecaster/config'

class TaleCaster_run_service(threading.Thread):
    def __init__(self, service, queue):
        super().__init__()

        self.queue = queue
        self.service = service
        global app
        app=TaleCasterApplication()
        app.indirect(service)

        method = (app.application_method)
        #if app.application_selftest is not None:
        #    selftest = (app.application_selftest)
        print(f"service {self.service}")
        self.run()

    def run(self):
        print("enter run")
        if app.application_method == 'runtime':
            print("os chdir")
            os.chdir(app.application_configdir)
            os.setgid(int(os.environ["tcgid"]))
            os.setuid(int(os.environ["tcuid"]))
            service_process = subprocess.Popen(executable=app.application_bin, args=app.application_args, shell=False)#, stdout=subprocess.STDOUT, stderr=subprocess.STDOUT)
            try:
                self.queue.put(service_process.communicate())
            except OSError:
                rich.print(prefix_service, "failed to start service {app.application}!")
                os._exit(service_process.returncode)

class TaleCaster_run_openvpn(threading.Thread):
    def __init__(self, openvpn_config, queue):
        super().__init__()

        self.openvpn_config = openvpn_config
        self.queue = queue

        global prefix_openvpn
        prefix_openvpn = "[[bold dark_orange]OpenVPN[/]]"
        ## Test for /dev/tun during __init__ to bail out quickly
        try:
            open("/dev/net/tun", "r")
        except:
            rich.print(prefix_openvpn, "[bold red]FATAL:[/] unable to open /dev/tun, check compose configuration.")
            ## Bail out quickly
            os._exit(100)

        self.run()

    ## This check should be simplified and before calling class.
    def run(self):
        message_prefix = "[[bold dark_orange]OpenVPN[/]]"
        ovpn_pidfile = "/run/openvpn.pid"
        openvpn_cmd = f'/usr/sbin/openvpn --config {self.openvpn_config} --log /var/log/openvpn.log --cd /talecaster/shared'
        
        ## XXX: needs /dev/tun check
        if self.openvpn_config is None:
            rich.print(prefix_openvpn, "[bold red]FATAL:[/] openvpn_config is undefined!")
            os._exit(200)
        try:
            ## Always run as root in the shared directory
            os.chdir("/talecaster/shared")
            os.setgid(0)
            os.setuid(0)
            ## Has to be done this way; if args aren't a single string, OpenVPN bails out.
            openvpn_process = subprocess.Popen(openvpn_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, user="root", group="root")
            rich.print(prefix_openvpn, "running as PID", openvpn_process.pid)
            self.queue.put(openvpn_process.pid)
            self.queue.put(openvpn_process.communicate())
        except:
            rich.print(prefix_openvpn, "[bold red]FATAL:[/] OpenVPN failed to start!")
            os._exit(100)