#!/bin/bash

database=$1
user=$2
address=$3
password=$4
port=$5

mysql -u$user -p"$password" --host=$address --port=$port -e "create database $database; grant all on $database.* to $user@$database;"


exit 0

