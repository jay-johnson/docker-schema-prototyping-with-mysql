FROM centos:7

# Define args and set a default value
ARG registry=hub.docker.com
ARG maintainer="Jay Johnson <jay.p.h.johnson@gmail.com>"
ARG imagename=schemaprototyping

MAINTAINER $maintainer
LABEL Vendor="Sample Vendor"
LABEL ImageType="Database Prototyping"
LABEL ImageName=$imagename
LABEL ImageOS=centos7
LABEL Version=1.0

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN groupadd -r apache && useradd -r -g apache apache

RUN mkdir /docker-entrypoint-initdb.d
RUN yum update -y && yum install -y perl curl binutils libaio pwgen wget

# gpg: key 5072E1F5: public key "MySQL Release Engineering <mysql-build@oss.oracle.com>" imported
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

# note: we're pulling the *.asc file from mysql.he.net instead of dev.mysql.com because the official mirror 404s that file for whatever reason - maybe it's at a different path?
RUN wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm -d && \
        yum localinstall mysql-community-release-el7-5.noarch.rpm -y && \
        yum install mysql-community-server -y && \
        rm mysql-community-release-el7-5.noarch.rpm && \
        yum clean all

RUN yum install -y MySQL-python epel-release
RUN yum install -y \
        python-pip \
        python-setuptools \
        net-tools \
        wget \
        curl \
        mlocate \
        boost \
        boost-devel \
        make \
        autoconf \
        gcc \
        libxml2-devel \
        perl \
        perl-devel \
        curl-devel \
        python-devel \
        libxslt \
        libxslt-devel \
        pcre-devel \
        gcc-c++ \
        sqlite-devel \
        procps \
        which \
        hostname \
        telnet \
        vim-enhanced \
        unzip

RUN easy_install pip && \
        /usr/bin/pip install --upgrade pip && \
        /usr/bin/pip install mimeparse \
        constants \
        flup \
        sqlalchemy \
        redis \
        lxml \
        pysqlite \
        simplejson \
        importlib \
        alembic && \
        /usr/bin/pip install pika==0.10.0

# Place VOLUME statement below all changes to /var/lib/mysql
VOLUME /var/lib/mysql
EXPOSE 80
EXPOSE 3306

ENV REBUILD_DB_ON_START 1
ENV PATH $PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts
ENV DATADIR /var/lib/mysql
ENV DBNAME stocks
ENV DBADDRESS 0.0.0.0
ENV DBHOST localhost
ENV DBPORT 3306
ENV DBUSER dbadmin
ENV DBPASS dbadmin123
ENV DBSCHEMA /opt/db-loaders/schema/db_schema.py
ENV DBINITIALIZER /opt/db-loaders/schema/initialize_db.py
ENV TERM dumb

# Add starters and installers
ADD ./container_files /opt/

# Configure files
RUN mkdir -p /opt/db-loaders && \
        mkdir /opt/shared && \
        mkdir /etc/phpMyAdmin && \
        mkdir /var/log/mysql && \
        mkdir -p /etc/mysql/conf.d && \
        touch /opt/reload_database && \
        touch /tmp/firsttimerunning && \
        cp /opt/db-loaders/bin/prepare_mysql_instance.sh /bin/prepare_mysql_instance.sh && \
        cp /opt/db-loaders/bin/flash_database_and_initialize.sh /bin/flash_database_and_initialize.sh && \
        cp /opt/db-loaders/bin/verify_mysql_user.sh /bin/verify_mysql_user.sh && \
        cp /opt/db-loaders/configs/my.cnf /etc/my.cnf && \
        cp /opt/db-loaders/configs/config.inc.php /etc/phpMyAdmin/ && \
        mv /opt/db-loaders/bin/start_container.sh /root/start_container.sh && \
        chmod 644 /etc/my.cnf && \
        chmod +x /bin/flash_database_and_initialize.sh && \
        chmod +x /bin/prepare_mysql_instance.sh && \
        chmod 777 /opt && \
        chmod 777 /opt/db-loaders && \
        chmod 777 /opt/db-loaders/bin/*.sh && \
        chmod 777 /opt/shared && \
        chmod 777 /root/*.sh

# Set the work dir
WORKDIR /opt/db-loaders

CMD ["/root/start_container.sh"]
