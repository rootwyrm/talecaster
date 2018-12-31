[![](https://images.microbadger.com/badges/image/rootwyrm/tc_deluge.svg)](https://microbadger.com/images/rootwyrm/tc_deluge "Get your own image badge on microbadger.com")

Containers need rebuilt with additional arguments:  --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun 

Deluge BitTorrent client. Work VERY MUCH IN PROGRESS.

- Need to build libtorrent due to Alpine not including rasterbar (ugh)
- Need to build deluge itself (python mess.)
