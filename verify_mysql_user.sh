#!/bin/bash

mysql -u$(cat docker-compose.yml | grep DBUSER | sed -e 's/=/ /g' | awk '{print $NF}') -p$(cat docker-compose.yml | grep DBPASS | sed -e 's/=/ /g' | awk '{print $NF}') -h127.0.0.1 -P3307

exit 0

