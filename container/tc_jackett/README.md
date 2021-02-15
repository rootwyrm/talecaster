# Jackett

[Jackett](https://github.com/Jackett/Jackett) - Torznab search proxying
![CICD - tc_jackett](https://github.com/rootwyrm/talecaster/workflows/CICD%20-%20tc_jackett/badge.svg)

# Regarding Auto-Updates
It is safe to update Jackett within the container, but not recommended. If there is a database update and you rebuild the container, your database may become corrupted or unusable. 

# Sample Setup
docker create -p 9119:9119 -v /opt/talecaster/blackhole:/talecaster/blackhole -v /opt/talecaster/config/jackett:/talecaster/config --name jackett docker.io/rootwyrm/tc_jackett:latest
