# ===== WORDPRESS  ===== #
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	mariadb-client \
	curl \
	unzip \
	less \
	vim \
	&& rm -rf /var/lib/apt/lists/*

# Create runtime directory for PHP-FPM socket
RUN mkdir -p /run/php

WORKDIR /var/www/html

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
RUN chmod +x /usr/local/bin/wordpress_setup.sh

EXPOSE 9000

# Start container with setup script
CMD ["/usr/local/bin/wordpress_setup.sh"]
