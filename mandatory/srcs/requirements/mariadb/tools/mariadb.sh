#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if ! -d /var/lib/mysql/mysql; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	service mariadb start

	until mariadb ping; do
		sleep 1;
	done

	mariadb -u root -e "CREATE DATABASE IF NOT EXISTS \`${MARIA_DB}\`;"
	mariadb -u root -e "CREATE USER IF NOT EXISTS '${USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';"
	mariadb -u root -e "GRANT ALL PRIVILEGES ON \`${MARIA_DB}\`.* TO '${USER}'@'%';"
	mariadb -u root -e "FLUSH PRIVILEGES;"
	mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';"
	mariadb-admin -u root -p"${ROOT_PASSWORD}" shutdown
fi
exec mariadbd --user=mysql
