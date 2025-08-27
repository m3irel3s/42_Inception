# ===== MARIA DB  ===== #
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	mariadb-server \
	&& rm -rf /var/lib/apt/lists/*

	
COPY ./conf/db.cnf /etc/mysql/db.cnf

EXPOSE 3306

CMD ["mysql"]