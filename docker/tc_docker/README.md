[![](https://images.microbadger.com/badges/image/rootwyrm/tc_docker.svg)](https://microbadger.com/images/rootwyrm/tc_docker "Get your own image badge on microbadger.com")

Base image for applications - you should never need to pull this yourself.

Containers need rebuilt with additional arguments:  --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun 
