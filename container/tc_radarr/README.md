# nzbget

nntp downloader

# Sample Setup
docker create -p 6789:6789 -v /media/config/nzbget:/config -v /media/download:/downloads --name testnzbget docker.io/rootwyrm/tc_nzbget:latest
