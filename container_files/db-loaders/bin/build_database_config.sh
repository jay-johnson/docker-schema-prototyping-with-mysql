#!/bin/bash

dbfile="/opt/db-loaders/configs/db.json"

dbname=$1
dbaddress=$2
dbport=$3
dbusername=$4
dbuserpass=$5
dbschema=$6
dbinit=$7

echo "{" >  $dbfile
echo -e "\t\"Database Applications\" : [" >> $dbfile
echo -e "\t\t{" >> $dbfile
echo -e "\t\t\t\"Name\":             \"$dbname\"," >> $dbfile
echo -e "\t\t\t\"Schema\":           \"$dbschema\"," >> $dbfile
echo -e "\t\t\t\"Initializer\":      \"$dbinit\"," >> $dbfile
echo -e "\t\t\t\"ExAddress List\":   \"$dbaddress:$dbport $dbaddress:$dbport\"," >> $dbfile
echo -e "\t\t\t\"Address List\":     \"127.0.0.1:$dbport localhost:$dbport\"," >> $dbfile
echo -e "\t\t\t\"Database Name\":    \"$dbname\"," >> $dbfile
echo -e "\t\t\t\"User\":             \"$dbusername\"," >> $dbfile
echo -e "\t\t\t\"Password\":         \"$dbuserpass\"," >> $dbfile
echo -e "\t\t\t\"Type\":             \"MySQL\"," >> $dbfile
echo -e "\t\t\t\"Autocommit\":       \"False\"," >> $dbfile
echo -e "\t\t\t\"Autoflush\":        \"False\"," >> $dbfile
echo -e "\t\t\t\"Debug\":            \"False\"" >> $dbfile
echo -e "\t\t}" >> $dbfile
echo -e "\t]" >> $dbfile

echo "}" >> $dbfile

exit 0
