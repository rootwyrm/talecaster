[![](https://images.microbadger.com/badges/image/rootwyrm/tc_headphones.svg)](https://microbadger.com/images/rootwyrm/tc_headphones "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/rootwyrm/tc_headphones.svg)](https://microbadger.com/images/rootwyrm/tc_headphones "Get your own version badge on microbadger.com")

**Important Note**: Python modules must be _built_ due to the Alpine package missing key functions (cryptography.hazmat.bindings.openssl.binding) used by python libs.

# Connection Information
https://ContainerHost:8181/ - only `https` will work as CouchPotato only listens on one port. You can disable `https` in the application after initial setup.

# Sample Setup
docker create -p 8181:8181 -v /media/config/headphones:/config -v /media/download:/downloads -v /media/headphones:/media/music --name=hptest docker.io/rootwyrm/lxc-media:headphones

# Todo
Reduce size further.. dependency chain for ffmpeg changed resulting in a massive 130MB+ local image. Should be able to pare down some of these requirements to get the amount on disk much lower.
