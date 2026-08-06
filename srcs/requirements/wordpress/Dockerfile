FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y mariadb-client php8.2-fpm php8.2-mysql curl && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -Os https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's/^listen.*/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/wordpress.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]