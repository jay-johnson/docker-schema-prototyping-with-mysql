#!/bin/sh

log="/tmp/dbinitialize.log"

DBNAME=$DBNAME
DBADDRESS=$DBADDRESS
DBHOST=$DBADDRESS
DBPORT=$DBPORT
DBUSER=$DBUSER
DBPASS=$DBPASS
DBSCHEMA=$DBSCHEMA
DBINITIALIZER=$DBINITIALIZER

echo "" > $log
echo "Starting DB Flash date:" >> $log
/bin/date >> $log
echo "" > $log

echo "" >> $log
echo "Checking for database reload hook" >> $log

if [ "$REBUILD_DB_ON_START" == "1" ]; then
  echo "" >> $log
  echo "Reloading database" >> $log
  echo "/opt/db-loaders/docker_reload_db.sh $DBNAME $DBADDRESS $DBPORT $DBUSER $DBPASS $DBSCHEMA $DBINITIALIZER" >> $log
  /opt/db-loaders/docker_reload_db.sh $DBNAME $DBADDRESS $DBPORT $DBUSER $DBPASS $DBSCHEMA $DBINITIALIZER
  rm /opt/reload_database
else
  echo "" >> $log
  echo "Not reloading the database" >> $log
fi

echo "" >> $log
echo "Done Flashing Database" >> $log
echo "" >> $log

exit 0
