**NOTE: This template is for RELEASE ISSUES only! Do not use for pre-release or internal issues.**

## Please fill out the platform information
```
[ ] Bare Metal Docker [ ] Virtualized Docker [ ] Kubernetes (any)
+---> [ ] Local Disk (incl. vSAN) [ ] Network Disk (incl. NFS, FCOE)
+---> [ ] Single Host [ ] Multiple Host
```

## Please mark the component
```
[ ] TaleCaster
[ ] TaleCaster Orchestration
[ ] VPN Subsystems (NOT FOR PROVIDER ISSUES)
[ ] TaleCaster Appliance Hardware (please contact support)
[ ] NZBget 
[ ] qBittorrent
[ ] Transmission
[ ] Sonarr
[ ] Radarr
[ ] Lidarr
[ ] Mylar
[ ] Readarr
[ ] PostgreSQL
```

## What version of TaleCaster are you using?
Please provide the tag (latest or devel) and the output of `docker inspect image <affected_image> | jq '.[].Id'` and `docker inspect --format='{{.Config.Labels}}' <affected_image>`

## Please describe the problem you are experiencing in detail.
A service not starting or crashing; a service not functioning as expected

## Is there anything special about your environment?
For example: Kubernetes deployments, Docker swarm cluster, remote downloader, etc.

## Please attach your /opt/talecaster/logs/talecaster.log below
**IMPORTANT: REMEMBER TO REDACT SENSITIVE INFORMATION!**
