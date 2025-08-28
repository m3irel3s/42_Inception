#!/bin/bash
set -e # exit immediately if a command fails

# Load secrets
DB_NAME=$(cat /run/secrets/db_name)
DB_USER=$(cat /run/secrets/db_user)
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_HOST=mariadb

WP_ADMIN=$(cat /run/secrets/wp_admin)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_ADMIN_EMAIL=$(cat /run/secrets/wp_admin_email)
WP_USER=$(cat /run/secrets/wp_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait for MariaDB
until mysql -u"$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -e "SELECT 1;" >/dev/null 2>&1; do
	echo "Waiting for database..."
	sleep 2
done

# Download WordPress if missing
if [ ! -f index.php ]; then
	echo "Downloading WordPress..."
	curl -O https://wordpress.org/latest.tar.gz
	tar -xzf latest.tar.gz --strip-components=1
	rm latest.tar.gz
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
		--url="https://localhost" \
		--title="Inception WP" \
		--admin_user="$WP_ADMIN" \
		--admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
		--skip-email \
		--allow-root
fi
