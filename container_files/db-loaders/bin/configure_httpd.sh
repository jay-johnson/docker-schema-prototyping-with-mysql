#/bin/bash

log="/tmp/httpd.log"

# This is not in the Dockerfile due to the Ubuntu
# Installing : httpd-2.4.6-40.el7.centos.x86_64
# Error unpacking rpm package httpd-2.4.6-40.el7.centos.x86_64
# error: unpacking of archive failed on file /usr/sbin/suexec: cpio: cap_set_file
# error: httpd-2.4.6-40.el7.centos.x86_64: install failed
if [ -e /tmp/firsttimerunning ]; then
    echo "Installing PHP and Apache" > $log
    mkdir -p /var/www/html >> $log
    mkdir -p /var/log/httpd >> $log
    chown -R apache:apache /var/log/httpd

    yum install -y httpd >> $log

    echo "" >> $log
    echo "Stopping HTTPD" >> $log
    pushd /tmp >> /dev/null
    rm -rf /run/httpd/* /tmp/httpd*
    kill -9 `ps auwwwx | grep httpd | grep -v grep | awk '{print $2}'` &> /dev/null
    
    echo "Installing config.inc.php" >> $log
    cp /etc/phpMyAdmin/config.inc.php /usr/share/phpMyAdmin/ >> $log
    echo "Installing phpMyAdmin.conf" >> $log
    cp /opt/db-loaders/configs/phpMyAdmin.conf /etc/httpd/conf.d/phpMyAdmin.conf >> $log
    chmod 644 /etc/httpd/conf.d/phpMyAdmin.conf
    echo "Installing httpd.conf" >> $log
    cp /opt/db-loaders/configs/httpd.conf /etc/httpd/conf/httpd.conf >> $log
    echo "Setting Permissions on /usr/share/phpMyAdmin" >> $log
    chown -R apache:apache /usr/share/phpMyAdmin
    popd >> /dev/null
fi
    
pushd /tmp >> /dev/null
echo "Starting the HTTPD" >> $log
nohup /usr/sbin/httpd -DFOREGROUND & >> $log
popd >> /dev/null

exit 0
