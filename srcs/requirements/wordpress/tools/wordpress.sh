#!/bin/bash

set -e

mkdir -p /run/php

while ! mariadb -h mariadb -u ${USER} -p${USER_PASSWORD}  &>/dev/null; do
	sleep 1;
done

if ! wp core is-installed --path=/var/www/html --allow-root; then

	echo "========fetching========"
	wp core download --path=/var/www/html --allow-root
	echo "========configuring========"
	wp config create \
    --dbname="$MARIA_DB_NAME" \
    --dbuser="$USER" \
    --dbpass="$USER_PASSWORD" \
    --dbhost="mariadb" \
    --path=/var/www/html \
    --allow-root

    echo "========installing========"
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_ADMIN_USER} \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=${WP_ADMIN_EMAIL} \
        --skip-email \
        --allow-root

    echo "===========Creating standard user============"
    wp user create \
        ${WP_USER} \
        ${WP_USER_EMAIL} \
        --role=author \
        --user_pass=${WP_USER_PASSWORD} \
        --allow-root

    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    chown -R www-data:www-data /var/www/html

fi

exec /usr/sbin/php-fpm8.2 -F 