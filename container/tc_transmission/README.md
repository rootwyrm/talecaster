# Transmission
![CICD - tc_transmission](https://github.com/rootwyrm/talecaster/workflows/CICD%20-%20tc_transmission/badge.svg)

# Sample Setup
docker create -p 9091:9091 -p 51413:51413/udp -v /opt/talecaster/config/torrent:/talecaster/config -v /opt/talecaster/download:/talecaster/downloads -v /opt/talecaster/blackhole:/talecaster/blackhole --name tc_transmission docker.io/rootwyrm/tc_transmission:latest
