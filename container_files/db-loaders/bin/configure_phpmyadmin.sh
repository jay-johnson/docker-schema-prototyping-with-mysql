#/bin/bash

log="/tmp/phpmyadmin.log"

# This is not in the Dockerfile due to the Ubuntu
# Installing : httpd-2.4.6-40.el7.centos.x86_64
# Error unpacking rpm package httpd-2.4.6-40.el7.centos.x86_64
# error: unpacking of archive failed on file /usr/sbin/suexec: cpio: cap_set_file
# error: httpd-2.4.6-40.el7.centos.x86_64: install failed
if [ -e /tmp/firsttimerunning ]; then
    yum install -y php php-mcrypt php-mysql phpmyadmin >> $log
fi

cp /opt/db-loaders/configs/config.inc.php /etc/phpMyAdmin/config.inc.php >> $log
sed -i "s/CHANGE_TO_DBNAME/$DBNAME/g" /etc/phpMyAdmin/config.inc.php >> $log
sed -i "s/CHANGE_TO_DBHOST/$DBHOST/g" /etc/phpMyAdmin/config.inc.php >> $log
sed -i "s/CHANGE_TO_DBPORT/$DBPORT/g" /etc/phpMyAdmin/config.inc.php >> $log
sed -i "s/CHANGE_TO_DBUSER/$DBUSER/g" /etc/phpMyAdmin/config.inc.php >> $log
sed -i "s/CHANGE_TO_DBPASS/$DBPASS/g" /etc/phpMyAdmin/config.inc.php >> $log
chmod 644 /etc/phpMyAdmin/config.inc.php

exit 0
