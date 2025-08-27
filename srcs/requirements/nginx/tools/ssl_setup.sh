#!/bin/bash
set -e  # exit immediately if a command fails

# === Check required environment variables ===
required_vars=(
	SSL_COUNTRY
	SSL_STATE
	SSL_LOCALITY
	SSL_ORG
	SSL_COMMON_NAME
	SSL_DAYS
	SSL_CERT_FOLDER
	SSL_CERTIFICATE
	SSL_KEY
)

for var in "${required_vars[@]}"; do
	if [ -z "${!var}" ]; then
		echo "[ERROR] Environment variable $var is not set. Please check .env file."
		exit 1
	fi
done

# === Ensure cert folder exists ===
mkdir -p "$SSL_CERT_FOLDER"

# === Generate SSL cert if missing ===
if [ ! -f "$SSL_CERTIFICATE" ] || [ ! -f "$SSL_KEY" ]; then
	echo "[INFO] Generating SSL certificate for CN=$SSL_COMMON_NAME..."
	openssl req -x509 -nodes -days "$SSL_DAYS" \
		-newkey rsa:2048 \
		-subj "/C=$SSL_COUNTRY/ST=$SSL_STATE/L=$SSL_LOCALITY/O=$SSL_ORG/CN=$SSL_COMMON_NAME" \
		-keyout "$SSL_KEY" \
		-out "$SSL_CERTIFICATE"
else
	echo "[INFO] Using existing SSL certificate."
fi

# === Execute CMD from Dockerfile ===
exec "$@"
