#!/bin/bash
set -e  # exit immediately if a command fails

DB_NAME=$(cat /run/secrets/db_name)
DB_USER=$(cat /run/secrets/db_user)
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Create /run/mysqld for the socket
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

DB_DATA_DIR="/var/lib/mysql"

# Initialize MariaDB if first time
if [ ! -d "$DB_DATA_DIR/mysql" ]; then
	echo "[INFO] Initializing MariaDB data directory..."
	mysql_install_db --user=mysql --datadir="$DB_DATA_DIR"

	echo "[INFO] Starting temporary MariaDB..."
	mysqld_safe --datadir="$DB_DATA_DIR" &
	sleep 5

	echo "[INFO] Creating database and users..."
	mysql -uroot <<-EOSQL
		CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
		CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
		GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
		ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
		FLUSH PRIVILEGES;
EOSQL

	echo "[INFO] Shutting down temporary MariaDB..."
	mysqladmin -uroot -p"$DB_ROOT_PASSWORD" shutdown
fi

exec gosu mysql "$@"
