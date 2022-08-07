# talecaster
TaleCaster - The Ultimate Media Management Solution

[![GitHub issues](https://img.shields.io/github/issues/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/issues)[![GitHub forks](https://img.shields.io/github/forks/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/network)[![GitHub stars](https://img.shields.io/github/stars/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/stargazers)[![GitHub license](https://img.shields.io/github/license/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster)

All credit goes to sgallagh for the name :)

[Sponsor on GitHub](https://github.com/sponsors/rootwyrm) | [Sponsor on Patreon](https://patreon.com/rootwyrm)

Our primary development environment is generously hosted by @rootwyrm using [Dragon North Enterprise Systems](https://www.dragonnorth.systems) BabyDragon Gen.5 and Gen.6 hardware. Available for purchase now.

Our secondary development hardware, named `alexandria.dragonnorth.systems`, is a Dragon North RedTail Gen.7B provided by [Dragon North Enterprise Systems](https://www.dragonnorth.systems).

![CC-BY-NC-4.0](https://i.creativecommons.org/l/by-nc/4.0/88x31.png)

## WARNING: Under active development. Pre-release software.

# Build Status
[![CICD - Release Build](https://github.com/rootwyrm/talecaster/actions/workflows/build_release.yml/badge.svg)](https://github.com/rootwyrm/talecaster/actions/workflows/build_release.yml)

# Linux - Docker
Docker-based 'basic' configurations are validated and working, and documentation is in progress!
TaleCaster is designed to be deployed using `docker-compose` as a full application suite and comes with a web front end.

# Linux - Kubernetes
Work is ongoing for a Kubernetes-friendlier version of TaleCaster. Note that you will require a persistent volume block driver such as [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner), [vsphere-csi-driver](https://github.com/kubernetes-sigs/vsphere-csi-driver), or [sig-sttorage-local-static-provisioner](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner).

# HALP PLEASE!
* Documentation! Documenting how to set up TaleCaster, Synology, etc.
* Actual web development for the frontend interface

# FreeBSD
Work on FreeBSD has been discontinued due to applications migrating to .NET Runtime. FreeBSD core and portmgr have been openly hostile to Mono and .NET, preventing any serious porting efforts. Existing installations should migrate to the Linux distribution of their preference and use Docker.
