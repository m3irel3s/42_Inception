#!/bin/bash
set -e # exit immediately if a command fails
set -x  # print each command before executing

# Load secrets
DB_NAME=$(cat /run/secrets/db_name)
DB_USER=$(cat /run/secrets/db_user)
DB_PASSWORD=$(cat /run/secrets/db_password)

WP_ADMIN=$(cat /run/secrets/wp_admin)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
WP_USER_EMAIL=$(cat /run/secrets/wp_user_email)

# Wait for MariaDB
until mysql -u"$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -e "SELECT 1;" >/dev/null 2>&1; do
	echo "Waiting for database..."
	sleep 2
done

# Download WordPress if missing
if [ ! -f index.php ]; then
	echo "Downloading WordPress..."
	rm -rf /var/www/html/*
	wp core download --allow-root
fi

# Generate wp-config.php
if [ ! -f wp-config.php ]; then
	cat > wp-config.php <<EOL
		<?php
		define('DB_NAME', '$DB_NAME');
		define('DB_USER', '$DB_USER');
		define('DB_PASSWORD', '$DB_PASSWORD');
		define('DB_HOST', '$DB_HOST');
		\$table_prefix  = 'wp_';

		define('WP_DEBUG', false);

		if ( !defined('ABSPATH') )
			define('ABSPATH', dirname(__FILE__) . '/');

		require_once(ABSPATH . 'wp-settings.php');
EOL
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
	echo "Installing WordPress..."

	wp core install \
		--url="$WP_URL" \
		--title="$WP_TITLE" \
		--admin_user="$WP_ADMIN" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--allow-root
	
	wp user create "$WP_USER" "$WP_USER_EMAIL" \
		--user_pass="$WP_USER_PASSWORD" \
		--role=subscriber \
		--allow-root
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

wp theme install twentytwentyfour --activate --allow-root

exec php-fpm8.2 -F
