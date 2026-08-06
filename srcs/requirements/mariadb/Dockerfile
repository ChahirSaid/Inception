FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y mariadb-server && \
	apt-get clean &&\
	rm -rf /var/lib/apt/lists/* && rm -rf /var/lib/mysql/*

RUN sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/mariadb.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]