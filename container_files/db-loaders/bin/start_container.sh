#!/bin/sh

log="/tmp/startcontainer.log"

# Handle Configuration on the First Time installing:
/opt/db-loaders/bin/configure_mysql.sh >> $log
/opt/db-loaders/bin/configure_phpmyadmin.sh >> $log
/opt/db-loaders/bin/configure_httpd.sh >> $log

echo "" > $log
echo "Starting container date:" >> $log
/bin/date >> $log
echo "" > $log

if [ "$REBUILD_DB_ON_START" == "1" ]; then
    pushd /usr/local/mysql/ /dev/null
    echo "" >> $log

    echo "Preparing MySQL from Dir(`pwd`)" >> $log
    /bin/prepare_mysql_instance.sh mysqld & >> $log
    echo "Waiting on Prepare" >> $log
    sleep 5
    echo "" >> $log
    echo "Done Preparing MySQL" >> $log
    popd >> /dev/null

    echo "" >> $log
    echo "Flashing and Initializing MySQL" >> $log
    /bin/flash_database_and_initialize.sh
else
    echo "Using existing Database in Dir: $DATADIR" >> $log
fi

if [ -e /tmp/firsttimerunning ]; then
    echo "Removing first time flag" >> $log
    rm -f /tmp/firsttimerunning >> $log
fi

echo "" >> $log
echo "Tailing the logs for keeping the container open" >> $log

tail -f $log
echo "" >> $log
echo "Container Wrapper Done" >> $log

exit 0
