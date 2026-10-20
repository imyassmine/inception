#!/bin/bash
set -e

until mysqladmin ping -h mariadb --silent; do
	sleep 1
done

if [ ! -f /var/www/html/wp-config.php ]; then
	wp core download --allow-root

	wp config create \
		--dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" --dbhost="mariadb" --allow-root

	wp core install \
		--url="${WP_URL}" --title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" --admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root

	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=editor --user_pass="${WP_USER_PASSWORD}" --allow-root
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
exec php-fpm8.2 -F
