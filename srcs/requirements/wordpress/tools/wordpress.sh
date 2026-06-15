#!/bin/bash

set -e

WP_PATH="/var/www/html"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB..."
until mariadb -h"${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -e "SELECT 1;" > /dev/null 2>&1; do
	sleep 1
done
echo "MariaDB is ready."

# First launch: download and configure WordPress
if [ ! -f "${WP_PATH}/wp-config.php" ]; then

	mkdir -p "${WP_PATH}"

	# Download WordPress core
	wp core download \
		--path="${WP_PATH}" \
		--allow-root

	# Generate wp-config.php
	wp config create \
		--path="${WP_PATH}" \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost="${MYSQL_HOST}" \
		--allow-root

	# Install WordPress (creates tables and sets up admin)
	wp core install \
		--path="${WP_PATH}" \
		--url="${WP_URL}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email \
		--allow-root

	# Create a second regular user
	wp user create \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--role=author \
		--user_pass="${WP_USER_PASSWORD}" \
		--path="${WP_PATH}" \
		--allow-root

fi

# Create the PHP-FPM runtime directory and start
mkdir -p /run/php
exec php-fpm8.2 -F
