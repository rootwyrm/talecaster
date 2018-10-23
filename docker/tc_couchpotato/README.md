[![](https://images.microbadger.com/badges/image/rootwyrm/tc_couchpotato.svg)](https://microbadger.com/images/rootwyrm/tc_couchpotato "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/rootwyrm/tc_couchpotato.svg)](https://microbadger.com/images/rootwyrm/tc_couchpotato "Get your own version badge on microbadger.com")

**Important Note**: Python modules must be _built_ due to the Alpine package missing key functions (cryptography.hazmat.bindings.openssl.binding) used by python libs.

CouchPotato will take you through the configuration wizard by design, so you can configure searches and logins. Directories are pre-configured so you should not need to change them.

# Connection Information
https://ContainerHost:5050/ - only `http` will work as CouchPotato doesn't support https

# Sample Advanced Setup
docker create -p 5050:5050 -v /media/config/couchpotato:/config -v /media/download:/downloads -v /media/movies :/media/movies --name=couchpotato docker.io/rootwyrm/tc_couchpotato:latest
