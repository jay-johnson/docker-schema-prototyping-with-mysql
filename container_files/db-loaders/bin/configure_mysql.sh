#/bin/bash

log="/tmp/mysql.log"

echo "Configuring mysql" > $log

echo "Updating my.cnf" >> $log
sed -i "s/REPLACE_DB_USER/$DBUSER/g" /etc/my.cnf  >> $log

cp /etc/my.cnf /etc/mysql/

exit 0
