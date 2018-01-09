# talecaster
TaleCaster - The Ultimate Media Management Solution

All credit goes to sgallagh for the name :)

Our primary development virtual environment, hosted on `shuhalo.rootwyrm.com`, `taunka.rootwyrm.com`, and `yaungol.rootwyrm.com` runs on VMware ESXi provided by Phillip R. Jaenke, and BabyDragon Gen.5 hardware from Dragon North Enterprise Systems.

Our primary development hardware, named `popcorn.rootwyrm.com`, is a Dell 2950-II generously donated by [ABCS-IT](https://www.reddit.com/user/abcs-it) with upgraded processors and additional memory from [sms552](https://www.reddit.com/user/sms552). 

## WARNING: Under active development. Pre-release software.

# Linux
Docker-based 'basic' configurations are validated and working, but not documented. This is not recommended for use at this time. Extensive work has been done to polish them up for individual module use but integration work is not complete. Advanced knowledge of disk and filesystem management is required to make use of these.

This is recommended for virtual environments and folks just looking to get an idea of how things work.

# FreeBSD
Work is ongoing for the fully-integrated jail-based system including local-router for VPN. IPv6 support is a long-term project. Most development work is occurring here right now, so this is a very active tree.

The FreeBSD configuration is specifically designed for dedicated hardware (e.g. Dell 2950, NAS-like, etc.) and makes extensive use of ZFS. 8GB of system is MANDATORY (minimum 16GB if using Mono-based applications.) Memory performance does not scale past 32GB unless using multiple tuners operating at 720p or higher. 

For multiple tuner systems, an SSD L2ARC is *very strongly* recommended specifically for the `talecaster/recording` FS. An SSD L2ARC is recommended for `talecaster/transcode` but not required.

**Tuner support is currently non-functional due to hardware availability.**
