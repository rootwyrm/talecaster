# Sonarr

Television series management, based on Servarr
![CICD - tc_sonarr](https://github.com/rootwyrm/talecaster/workflows/CICD%20-%20tc_sonarr/badge.svg)

# Regarding Auto-Updates
It is safe to update Sonarr within the container, but not recommended. If there is a database update and you rebuild the container, your database may become corrupted or unusable. However, Sonarr v3 does not have a configuration knob to disable updates at this time.

# Sample Setup
docker create -p 8989:8989 -v /opt/talecaster/config/television:/talecaster/config -v /opt/talecaster/downloads:/talecaster/downloads --name sonarr docker.io/rootwyrm/tc_sonarr:latest
