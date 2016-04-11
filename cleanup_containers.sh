#!/bin/bash

source common.sh .

echo "Stopping the Docker Container"
docker-compose stop

echo "Cleaning up the Docker Container"
docker stop $imagename
docker rm $imagename
docker rmi $maintainer/$imagename

exit 0
