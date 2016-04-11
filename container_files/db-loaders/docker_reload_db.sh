#!/bin/bash

log="/tmp/dbreload.log"

envname="Local"

echo "" > $log
echo "Starting DB Reload date:" >> $log
/bin/date >> $log
echo "" > $log

# Parse the Database Initializers for loading this test database: 
dbname=$1
dbaddress=$2
dbhost=$2
dbport=$3
dbusername=$4
dbuserpass=$5
dbschema=$6
dbinit=$7

echo "" >> $log
echo "Creating Database($dbname) on Env($envname)" >> $log
echo "" >> $log

# Drop the existing one if there is one
echo "Dropping Targeted Database($dbname) Address($dbaddress) User($dbusername) Pass($dbuserpass) Schema($dbschema) Init($dbinit)" >> $log
echo "/opt/db-loaders/schema/drop_database.sh $dbname $dbusername $dbhost $dbuserpass $dbport" >> $log
/opt/db-loaders/schema/drop_database.sh $dbname $dbusername $dbhost $dbuserpass $dbport

# Create a new database
echo "Creating Targeted Database($dbname) Address($dbaddress) User($dbusername) Pass($dbuserpass) Schema($dbschema) Init($dbinit)" >> $log
echo "/opt/db-loaders/schema/create_database.sh $dbname $dbusername $dbhost $dbuserpass $dbport" >> $log
/opt/db-loaders/schema/create_database.sh $dbname $dbusername $dbhost $dbuserpass $dbport

# Initialize the database by processing the stock csv files using the database initializers
echo "Adding Records with Initializer($dbinit)" >> $log
echo "/opt/db-loaders/bin/build_database_config.sh $dbname $dbhost $dbport $dbusername $dbuserpass $dbschema $dbinit" >> $log
/opt/db-loaders/bin/build_database_config.sh $dbname $dbhost $dbport $dbusername $dbuserpass $dbschema $dbinit

echo "" >> $log
echo "New Configuration: /opt/db-loaders/configs/db.json" >> $log
cat /opt/db-loaders/configs/db.json

# Initialize the database by processing the stock csv files using the database initializers
echo "" >> $log
echo "Waiting for the database to be created" >> $log
sleep 5
echo "" >> $log
echo "Adding Records with Initializer($dbinit)" >> $log
echo "$dbinit -e $envname" >> $log
$dbinit -e $envname >> $log

echo "" >> $log
echo "Done Creating Database($dbname) on Env($envname)" >> $log
echo "" >> $log

exit 0

