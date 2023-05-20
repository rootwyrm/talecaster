# sabnzbd

[SABnzbd](https://sabnzbd.org/)
Usenet (NNTP) downloader implemented in Python. Replacing NZBget, as NZBget development has been discontinued.

## Important Notes
SABnzbd uses a dangerously common port (8080/webcache) by default, which also violates IETF standards. Applications must never default to an assigned port unless they provide the service defined by that port. 

We insist on running SABnzbd on a safe port instead - 6789, same as NZBget.

# Sample Setup
docker create -p 6789:6789 -v /talecaster/config/nntp:/config -v /talecaster/downloads:/downloads --name nntp docker.io/rootwyrm/tc_nzbget:latest
