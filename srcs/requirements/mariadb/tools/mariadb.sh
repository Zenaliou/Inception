#!/bin/bash

set -e

# Create the socket directory and give it to mysql user
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Read passwords from Docker secrets
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# First launch: initialize the database
if [ ! -d "/var/lib/mysql/mysql" ]; then

	# Create the base system tables
	mysql_install_db --user=mysql --datadir=/var/lib/mysql

	# Run SQL commands once to set up our database and users
	mysqld --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
ALTER USER 'root'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD('${MYSQL_ROOT_PASSWORD}');
FLUSH PRIVILEGES;
EOF

fi

# Start MariaDB (replaces the current process)
exec mysqld --user=mysql
