[![](https://images.microbadger.com/badges/image/rootwyrm/tc_lazylibrarian.svg)](https://microbadger.com/images/rootwyrm/tc_lazylibrarian "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/rootwyrm/tc_lazylibrarian.svg)](https://microbadger.com/images/rootwyrm/tc_lazylibrarian "Get your own version badge on microbadger.com")

**Important Note**: Python modules must be _built_ due to the Alpine package missing key functions (cryptography.hazmat.bindings.openssl.binding) used by python libs.

# Connection Information
https://ContainerHost:5299/ - only `https` will work as LazyLibrarian only listens on one port. You can disable `https` in the application after initial setup.

# Sample Setup
docker create -p 5299:5299 -v /media/config/lazylibrarian:/config -v /media/download:/downloads -v /media/books:/media/books --name=lltest docker.io/rootwyrm/tc_lazylibrarian:latest
