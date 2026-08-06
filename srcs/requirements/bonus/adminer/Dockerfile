FROM debian:bookworm

RUN apt-get update && apt-get install -y adminer php && \
	cp /usr/share/adminer/adminer.php /var/www/html/index.php

ENTRYPOINT [ "php", "-S", "0.0.0.0:8080", "-t",  "/var/www/html" ]