[![](https://images.microbadger.com/badges/image/rootwyrm/tc_sonarr.svg)](https://microbadger.com/images/rootwyrm/tc_sonarr "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/rootwyrm/tc_sonarr.svg)](https://microbadger.com/images/rootwyrm/tc_sonarr "Get your own version badge on microbadger.com")

# Connection Information
https://ContainerHost:8989/ - WORK IN PROGRESS

# Sample Setup
docker create -p 8989:8989 -v /media/config/sonarr:/config -v /media/download:/downloads -v /media/television:/media/television --name=sontest docker.io/rootwyrm/tc_sonarr
