FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/conf.d/file.conf


RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt  -keyout /etc/nginx/ssl/inception.key -subj "/CN=schahir.42.fr"

RUN mkdir -p /var/run/nginx

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;"]