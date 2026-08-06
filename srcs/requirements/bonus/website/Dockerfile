FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx

COPY webpage.html /var/www/html

COPY image.jpg /var/www/html

COPY conf/nginx.conf /etc/nginx/conf.d/file.conf

ENTRYPOINT [ "nginx", "-g",  "daemon off;"]