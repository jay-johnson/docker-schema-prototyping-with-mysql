## Prototyping a MySQL Schema with Docker and phpMyAdmin

### Overview

This repository is for rapid-prototyping a schema using a MySQL Docker container that deploys your ORM schema file and populates the initial records on start up.

By setting a couple environment variables, you can provision your own Docker container with a usable MySQL instance, browser-ready phpMyAdmin server, and your database including the tables initialized exactly how you want. This repository was built for building and testing schemas with actual data before promoting + migrating changes to a database on another environment. This repository comes with a sample stock Schema file and MSFT and IBM data stored in CSV files, and I use this as part of my machine learning experiments on the stock market.

[Schema Prototyping Container on Docker Hub](https://hub.docker.com/r/jayjohnson/schemaprototyping)

#### Repository Layout

```
├── build.sh - build the container
├── cleanup_containers.sh - stop + clean up the container
├── common.sh - common names exposed to the driver scripts to manage the composition
├── container_files - added into the container at: /opt/
│   └── db-loaders - database driver and initialization scripts
│       ├── bin 
│       │   ├── build_database_config.sh - build the db json config file from the env vars
│       │   ├── configure_httpd.sh - configure httpd from the env vars
│       │   ├── configure_mysql.sh - configure MySQL from the env vars
│       │   ├── configure_phpmyadmin.sh - configure phpMyAdmin from the env vars
│       │   ├── flash_database_and_initialize.sh - flash the database with the new seed data
│       │   ├── prepare_mysql_instance.sh - prepare the MySQL instance for first-time use
│       │   ├── start_container.sh - Dockerfile CMD script 
│       │   └── verify_mysql_user.sh - helper for validating MySQL is working from inside the container
│       ├── configs
│       │   ├── config.inc.php - phpMyAdmin config file stored: /etc/phpMyAdmin/config.inc.php
│       │   ├── db.json - used by the sqlaclhemy tools to create a session
│       │   ├── httpd.conf - apache config stored: /etc/httpd/httpd.conf
│       │   ├── my.cnf - mysql confi stored: /etc/my.cnf
│       │   └── phpMyAdmin.conf - apache phpMyAdmin config stored: /etc/httpd/conf.d/phpMyAdmin.conf
│       ├── data
│       │   ├── IBM.csv - IBM stock seed data
│       │   └── MSFT.csv - MSFT stock seed data
│       ├── docker_reload_db.sh - helper for reloading the database with new seed data
│       ├── schema
│       │   ├── create_database.sh - helper to create the database
│       │   ├── db_schema.py - SQLAclhemy Schema file
│       │   ├── drop_database.sh - helper for dropping the database
│       │   ├── initialize_db.py - helper for initializing the database from the db_schema.py file
│       └── src
│           ├── logger.py - syslog wrapper
│           └── utils.py - generic python utils
├── docker-compose.yml - Docker compose file
├── Dockerfile - Docker container image file
├── ssh.sh - ssh into the container (references the common.sh)
├── start_composition.sh - start the composition
├── stop_composition.sh - stop the composition
└── verify_mysql_user.sh - helper for verifying the host can open a MySQL console to the container's db
```

### Getting Started


1. Start Docker Compose

    ```
    $ ./start_composition.sh
    Starting with Docker Compose
    Pulling db (jayjohnson/schemaprototyping:latest)...
    latest: Pulling from jayjohnson/schemaprototyping
    a3ed95caeb02: Pull complete
    5989106db7fb: Pull complete
    75e2f0ff048c: Pull complete
    98d3fe0e5a2b: Pull complete
    cb2b06526018: Pull complete
    d3f18fb8fd93: Pull complete
    dbbbb36603a9: Pull complete
    fea73f54e760: Pull complete
    590f6232d0c3: Pull complete
    7a4d25f8a269: Pull complete
    c8dd899cb1db: Pull complete
    b2540ace42c3: Pull complete
    b5b1828daba4: Pull complete
    Digest: sha256:a4df1305df7bb306c3338b365ad945cee1f87d282d6672b331d69f8832856b63
    Status: Downloaded newer image for jayjohnson/schemaprototyping:latest
    Creating schemaprototyping
    $
    ```

1. Check the composition is running

    ```
    $ docker ps -a
    CONTAINER ID        IMAGE                          COMMAND                  CREATED              STATUS              PORTS                                        NAMES
    74b3b71e19e0        jayjohnson/schemaprototyping   "/root/start_containe"   About a minute ago   Up 27 seconds       0.0.0.0:81->80/tcp, 0.0.0.0:3307->3306/tcp   schemaprototyping
    $
    ```

1. Verify the Database with the MySQL CLI

    From the Host you can verify connectivity with:

    ```
    $ ./verify_mysql_user.sh 
    Warning: Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 5
    Server version: 5.6.29 MySQL Community Server (GPL)

    Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> quit
    Bye
    $
    ```

    From inside the container you can verify connectivity with:

    ```
    $ ./ssh.sh 
    SSH-ing into Docker image(schemaprototyping)
    [root@mysql1 db-loaders]# /opt/db-loaders/bin/verify_mysql_user.sh
    Warning: Using a password on the command line interface can be insecure.
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 25
    Server version: 5.6.29 MySQL Community Server (GPL)

    Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

    mysql> quit
    Bye
    [root@mysql1 db-loaders]# 
    ```

1. Login to phpMyAdmin from a browser at: ``http://localhost:81/phpMyAdmin``

    ![Login to phpMyAdmin at: http://localhost:81/phpMyAdmin](./readme-images/DockerSchemaProtoTypingHints.png)

1. Examine the Stocks DB and Table

    ![Login to phpMyAdmin at: http://localhost:81/phpMyAdmin](./readme-images/DockerSchemaProtoTypingStockDB.png)

### Changing the Composition

The docker-compose.yml file is reponsible for assigning environment variables that drive the container's configuration management as it starts running. To change the composition:

1. Check if the composition is running

    ```
    $ docker ps -a
    CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                                        NAMES
    17a015959564        jayjohnson/schemaprototyping   "/root/start_containe"   2 minutes ago       Up 2 minutes        0.0.0.0:81->80/tcp, 0.0.0.0:3307->3306/tcp   schemaprototyping
    $ 
    ```

1. Stop the composition

    ```
    $ ./stop_composition.sh 
    Stopping with Docker Compose
    Stopping schemaprototyping ... done
    $
    ```

1. Edit the docker-compose.yml file

    Here are the supported, default environment variable values:

    ```
    $ cat docker-compose.yml | grep "=" | sort
      - DATADIR=/var/lib/mysql
      - DBADDRESS=127.0.0.1
      - DBHOST=127.0.0.1
      - DBINITIALIZER=/opt/db-loaders/schema/initialize_db.py
      - DBNAME=stocks
      - DBPASS=dbadmin123
      - DBPORT=3306
      - DBSCHEMA=/opt/db-loaders/schema/db_schema.py
      - DBUSER=dbadmin
      - REBUILD_DB_ON_START=1
    $
    ```

1. Save the changes to the docker-compose.yml

1. Start the composition

    ```
    $ ./start_composition.sh 
    Starting with Docker Compose
    Recreating schemaprototyping
    $ 
    ```

### Examine the Schema and data with phpMyAdmin

1. To examine your new database open your local browser to:

[http://localhost:81/phpmyadmin/](http://localhost:81/phpmyadmin/)

1. The default login for this database is: 

[dbadmin / dbadmin123](https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/docker-compose.yml#L9-L10)


### Stop the Container

```
$ ./stop_containers.sh 
Stopping with Docker Compose
Stopping schemaprototyping ... done
$
```

### Want to use your own Schema?

Just override the db_schema.py file:

[https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/db-loaders/schema/db_schema.py](https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/db-loaders/schema/db_schema.py)

### Want to initialize the Database with some records?

Just define your own method:

https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/db-loaders/schema/initialize_db.py

By default this container writes the CSV files from the [data](https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/tree/master/db-loaders/data) directory and [adds the the the database by iterating over the CSV files](https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/db-loaders/schema/initialize_db.py#L106-L195)

### Use the MySQL Instance

By default the mysql instance is listening on your host at: ```0.0.0.0:3307``` with a mysql uri: ```mysql://dbadmin:dbadmin123@0.0.0.0:3307/stocks```, but you can change it [here](https://github.com/jay-johnson/docker-schema-prototyping-with-mysql/blob/master/docker-compose.yml#L15)

### Building the Container

Build the container:

```
$ ./build.sh 
Building new Docker image(docker.io/jayjohnson/schemaprototyping)
$
```


### Troubleshooting and Debugging

There is a [known issue building httpd on Ubuntu](https://github.com/docker/hub-feedback/issues/461) so this container uses the [container_files/db-loaders/bin/configure_phpmyadmin.sh](/docker-schema-prototyping-with-mysql/tree/master/db-loaders/bin/configure_phpmyadmin.sh) and [container_files/db-loaders/bin/configure_httpd.sh](/docker-schema-prototyping-with-mysql/tree/master/db-loaders/bin/configure_httpd.sh) to install apache and php after starting. This means the container can take a few seconds to download and yum install these components. I plan on fixing this once the issue is resolved, but for now please be patient and things should start up.

#### Internal Container Applications and Components

This container runs on a [Centos 7](https://hub.docker.com/_/centos/) OS and hosts the following applications

1. SSH into the container

    ```
    $ ./ssh.sh 
    SSH-ing into Docker image(schemaprototyping)
    [root@mysql1 db-loaders]# 
    ```

1. MySQL - Exposed to the Host on TCP Port 3307 and inside the container on TCP Port 3306

    ```
    [root@mysql1 db-loaders]# ps auwwx | grep mysql | grep -v grep
    root       180  0.0  0.0  11780  2596 ?        S    02:28   0:00 /bin/sh /usr/bin/mysqld_safe
    mysql      810  0.1  9.3 1267320 467684 ?      Sl   02:28   0:00 /usr/sbin/mysqld --basedir=/usr --datadir=/var/lib/mysql --plugin-dir=/usr/lib64/mysql/plugin --user=mysql --log-error=/var/log/mysql/error.log --pid-file=/var/lib/mysql/mysqld.pid --socket=/var/lib/mysql/mysqld.sock --port=3306
    [root@mysql1 db-loaders]# 
    ```

1. PhpMyAdmin

    ```
    [root@mysql1 db-loaders]# ls /etc/phpMyAdmin/config.inc.php
    /etc/phpMyAdmin/config.inc.php
    [root@mysql1 db-loaders]# 
    ```

1. Apache - listening to incoming HTTP requests on ```http://localhost:81/phpMyAdmin```

    ```
    [root@mysql1 db-loaders]# ps auwwx | grep httpd
    root       171  0.0  0.4 397040 24080 ?        S    02:28   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     240  0.0  0.4 405304 23984 ?        S    02:28   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     245  0.0  0.3 398908 15408 ?        S    02:28   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     246  0.0  0.3 398952 15840 ?        S    02:28   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     247  0.0  0.3 399472 16416 ?        S    02:28   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     857  0.1  0.5 405352 27532 ?        S    02:29   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     860  0.0  0.4 403000 22176 ?        S    02:30   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     861  0.0  0.4 401200 20340 ?        S    02:30   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     862  0.0  0.3 399456 16548 ?        S    02:30   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     863  0.0  0.5 406108 25264 ?        S    02:30   0:00 /usr/sbin/httpd -DFOREGROUND
    apache     866  0.0  0.1 397040  8464 ?        S    02:30   0:00 /usr/sbin/httpd -DFOREGROUND
    root       899  0.0  0.0   9044   868 ?        S+   02:37   0:00 grep --color=auto httpd
    [root@mysql1 db-loaders]# 
    ```

#### Logs

By default all logs during the container's initialization are stored in ```/tmp```

```
[root@mysql1 db-loaders]# ls /tmp/*.log
/tmp/dbinitialize.log  /tmp/dbreload.log  /tmp/httpd.log  /tmp/mysql.log  /tmp/phpmyadmin.log  /tmp/prepare.log  /tmp/startcontainer.log
[root@mysql1 db-loaders]# 
```

These logs are the output of the configuration management scripts

```
container_files/db-loaders/bin$ grep "log=" *
configure_httpd.sh:log="/tmp/httpd.log"
configure_mysql.sh:log="/tmp/mysql.log"
configure_phpmyadmin.sh:log="/tmp/phpmyadmin.log"
flash_database_and_initialize.sh:log="/tmp/dbinitialize.log"
prepare_mysql_instance.sh:log="/tmp/prepare.log"
start_container.sh:log="/tmp/startcontainer.log"
container_files/db-loaders/bin$ 
```

Apache logs

```
[root@mysql1 db-loaders]# ls /var/log/httpd/
access_log  error_log
[root@mysql1 db-loaders]# 
```

MySQL logs

```
[root@mysql1 db-loaders]# ls /var/log/mysql/error.log 
/var/log/mysql/error.log
[root@mysql1 db-loaders]#
```

By default the MySQL Database Dir is in ```/var/lib/mysql```

```
[root@mysql1 db-loaders]# ls /var/lib/mysql/
auto.cnf  ib_logfile0  ib_logfile1  ibdata1  mysql  mysqld.pid  mysqld.sock  performance_schema  stocks
[root@mysql1 db-loaders]# 
```

#### Database Initialization

Examine how the database initialized with the /tmp/dbreload.log file:

```
[root@mysql1 db-loaders]# cat /tmp/dbreload.log


Creating Database(stocks) on Env(Local)

Dropping Targeted Database(stocks) Address(127.0.0.1) User(dbadmin) Pass(dbadmin123) Schema(/opt/db-loaders/schema/db_schema.py) Init(/opt/db-loaders/schema/initialize_db.py)
/opt/db-loaders/schema/drop_database.sh stocks dbadmin 127.0.0.1 dbadmin123 3306
Creating Targeted Database(stocks) Address(127.0.0.1) User(dbadmin) Pass(dbadmin123) Schema(/opt/db-loaders/schema/db_schema.py) Init(/opt/db-loaders/schema/initialize_db.py)
/opt/db-loaders/schema/create_database.sh stocks dbadmin 127.0.0.1 dbadmin123 3306
Adding Records with Initializer(/opt/db-loaders/schema/initialize_db.py)
/opt/db-loaders/bin/build_database_config.sh stocks 127.0.0.1 3306 dbadmin dbadmin123 /opt/db-loaders/schema/db_schema.py /opt/db-loaders/schema/initialize_db.py

New Configuration: /opt/db-loaders/configs/db.json

Waiting for the database to be created

Adding Records with Initializer(/opt/db-loaders/schema/initialize_db.py)
/opt/db-loaders/schema/initialize_db.py -e Local

Performing Action(Building DB Initial Records)
DB({"Autocommit": "False", "Database Name": "stocks", "Name": "stocks", "ExAddress List": "127.0.0.1:3306 127.0.0.1:3306", "Initializer": "/opt/db-loaders/schema/initialize_db.py", "Autoflush": "False", "Address List": "127.0.0.1:3306 localhost:3306", "User": "dbadmin", "Debug": "False", "Password": "dbadmin123", "Type": "MySQL", "Schema": "/opt/db-loaders/schema/db_schema.py"})

Adding Stock Records
Building Engine
Connecting Engine with SQLAddr(mysql://dbadmin:dbadmin123@127.0.0.1:3306/stocks)
Loading all Schema Modules
Adding Class DB Name(BT_Stocks) if not created
Total Stock CSV Files to Import(2)
Ticker(MSFT) - Adding Stock Points DB Records(2514)
Ticker(MSFT) - Done Adding Stock Points DB Records(2514)
Ticker(IBM) - Adding Stock Points DB Records(2515)
Ticker(IBM) - Done Adding Stock Points DB Records(2515)
Done Building Stock DB
DB Records created successfully

Done Creating Database(stocks) on Env(Local)

[root@mysql1 db-loaders]# 
```


### License

Apache 2.0 License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



