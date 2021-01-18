#!/bin/bash

docker image prune -y
docker rmi tc_docker tc_dotnet tc_radarr
docker build tc_docker/ -t tc_docker
docker build tc_dotnet/ -t tc_dotnet
docker build tc_radarr/ -t tc_radarr
