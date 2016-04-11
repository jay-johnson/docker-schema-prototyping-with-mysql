#!/bin/bash

log="/tmp/prepare.log"

echo "" > $log
echo "Preparing DB" >> $log
echo "" >> $log


set -e

# if command starts with an option, prepend mysqld
if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

MYSQL_USER=$DBUSER
MYSQL_PASSWORD=$DBPASS
MYSQL_DATABASE=$DBNAME
MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD
if [ "$1" = 'mysqld' ]; then

    echo "" >> $log
    echo "Setting Data dir:" >> $log
	# Get config
	DATADIR="$("$@" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
    echo "$DATADIR" >> $log

    echo "" >> $log
    echo "Setting Data dir:" >> $log

    if [ ! -d "$DATADIR/mysql" ]; then
		if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" -a -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			echo >&2 'error: database is uninitialized and password option is not specified ' >> $log
			echo >&2 '  You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD' >> $log
			exit 1
		fi
		mkdir -p "$DATADIR"
		chown -R mysql:mysql "$DATADIR"

        pushd /usr/share/mysql/ >> $log
		echo 'Initializing database' >> $log
		mysql_install_db --user=mysql --datadir=$DATADIR --rpm 
		echo 'Database initialized' >> $log
        popd >> $log

		"$@" --basedir=/usr/local/mysql &
		pid="$!"

		mysql=( mysql --protocol=socket -uroot )

		for i in {30..0}; do
			if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
				break
			fi
			echo 'MySQL init process in progress...' >> $log
			sleep 1
		done
		if [ "$i" = 0 ]; then
			echo >&2 'MySQL init process failed.' >> $log
			exit 1
		fi

		if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
			# sed is for https://bugs.mysql.com/bug.php?id=20545
			mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
		fi

		if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
			MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
			echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD" >> $log
		fi
        echo "" >> $log
        echo "Creating root and mysql Users" >> $log
		"${mysql[@]}" <<-EOSQL
			-- What's done in this file shouldn't be replicated
			--  or products like mysql-fabric won't work
			SET @@SESSION.SQL_LOG_BIN=0;

			DELETE FROM mysql.user ;
			CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			CREATE USER 'mysql'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
			GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
			GRANT ALL ON *.* TO 'mysql'@'%' WITH GRANT OPTION ;
			DROP DATABASE IF EXISTS test ;
			FLUSH PRIVILEGES ;
			FLUSH HOSTS ;
		EOSQL

		if [ ! -z "$MYSQL_ROOT_PASSWORD" ]; then
			mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )
		fi
        echo "" >> $log
        echo "Creating $MYSQL_DATABASE database" >> $log
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"

        echo "" >> $log
        echo "Creating $MYSQL_USER user" >> $log
        echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
        echo "GRANT ALL ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION ;" | "${mysql[@]}"

        echo "" >> $log
        echo "Granting $MYSQL_USER root mysql access to the $MYSQL_DATABASE database" >> $log
        echo "GRANT ALL ON $MYSQL_DATABASE.* TO 'root'@'%';" | "${mysql[@]}"
        echo "GRANT ALL ON $MYSQL_DATABASE.* TO 'mysql'@'%';" | "${mysql[@]}"
        echo "GRANT ALL ON $MYSQL_DATABASE.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
        echo "GRANT ALL ON $MYSQL_DATABASE.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
        echo "GRANT ALL ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION ;" | "${mysql[@]}"
        echo "GRANT ALL ON *.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
        echo "GRANT ALL ON *.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"
    
        echo "" >> $log
        echo "Flushing Privileges" >> $log
        echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
        mysql+=( "$MYSQL_DATABASE" )

		echo
		for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)  echo "$0: running $f"; . "$f" ;;
				*.sql) echo "$0: running $f"; "${mysql[@]}" < "$f" && echo ;;
				*)     echo "$0: ignoring $f" ;;
			esac
			echo
		done

		if ! kill -s TERM "$pid" || ! wait "$pid"; then
			echo >&2 'MySQL init process failed.' >> $log
			exit 1
		fi

		echo
		echo 'MySQL init process done. Ready for start up.' >> $log
		echo
	fi

	chown -R mysql:mysql "$DATADIR"
fi

echo "Starting MySQL" >> $log
nohup /usr/bin/mysqld_safe & >> $log
echo "Done Starting MySQL" >> $log

exit 0
