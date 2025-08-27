# ===== NGINX  ===== #
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	nginx \
	openssl \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/ssl_setup.sh /usr/local/bin/ssl_setup.sh

RUN chmod +x /usr/local/bin/ssl_setup.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/ssl_setup.sh"]

CMD ["nginx", "-g", "daemon off;"]
