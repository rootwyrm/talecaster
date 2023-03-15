# talecaster
TaleCaster - The Ultimate Media Management Solution

# IMPORTANT: Image Migration!

**Due to [Docker Hub's extreme hostility toward open source(https://blog.alexellis.io/docker-is-deleting-open-source-images/)], images will be migrating to a new registry. I do not have several hundred dollars per year and this project certainly doesn't. Please stay tuned.**

[![GitHub issues](https://img.shields.io/github/issues/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/issues)[![GitHub forks](https://img.shields.io/github/forks/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/network)[![GitHub stars](https://img.shields.io/github/stars/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster/stargazers)[![GitHub license](https://img.shields.io/github/license/rootwyrm/talecaster?style=for-the-badge)](https://github.com/rootwyrm/talecaster)

All credit goes to sgallagh for the name :)

[Sponsor on GitHub](https://github.com/sponsors/rootwyrm) | [Sponsor on Patreon](https://patreon.com/rootwyrm)

Our primary development environment is generously hosted by @rootwyrm using [Dragon North Enterprise Systems](https://www.dragonnorth.systems) BabyDragon Gen.5 and Gen.6 hardware. Available for purchase now.

Our secondary development hardware, named `alexandria.dragonnorth.systems`, is a Dragon North RedTail Gen.7B provided by [Dragon North Enterprise Systems](https://www.dragonnorth.systems).

## WARNING: Under active development. Pre-release software.



# Build Status
| Base Image                                                                                                        |                                                                                                                     |                                                                                                                   |                                                                                                                         |                                                                                                                    |
|-------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_docker) | Web UI                                                                                                              | NZBget                                                                                                            | Transmission                                                                                                            |                                                                                                                    |
| Mono                                                                                                              | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_frontend) | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_nzbget) | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_transmission) |                                                                                                                    |
| ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_mono)   | Sonarr                                                                                                              | Radarr                                                                                                            | Lidarr                                                                                                                  | Jackett                                                                                                            |
|                                                                                                                   | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_sonarr)   | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_radarr) | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_lidarr)       | ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rootwyrm/talecaster/CICD%20-%20tc_jackett) |


# Linux
Docker-based 'basic' configurations are validated and working, and documentation is in progress!
TaleCaster is designed to be deployed using `docker-compose` as a full application suite and comes with a web front end.

# HALP PLEASE!
* Documentation! Documenting how to set up TaleCaster, Synology, etc.
* The build status table is a nightmare. There has to be a better way?

# FreeBSD
Work on FreeBSD has been discontinued due to applications migrating to .NET Runtime. FreeBSD core and portmgr have been openly hostile to Mono and .NET, preventing any serious porting efforts. Existing installations should migrate to the Linux distribution of their preference and use Docker.
