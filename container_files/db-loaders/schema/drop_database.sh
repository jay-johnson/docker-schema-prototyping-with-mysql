#!/bin/bash

database=$1
user=$2
address=$3
password=$4
port=$5

mysql -u$user -p"$password" --host=$address --port=$port -e "drop database $database;"

exit 0

