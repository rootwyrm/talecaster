# nzbget

nntp downloader

# Sample Setup
docker create -p 6789:6789 -v /talecaster/config/nntp:/config -v /talecaster/downloads:/downloads --name nntp docker.io/rootwyrm/tc_nzbget:latest
