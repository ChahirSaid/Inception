FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server && \
	apt-get clean && rm -rf /var/apt/lists/

COPY ./conf/redis.conf /etc/redis/redis.conf

ENTRYPOINT [ "redis-server", "/etc/redis/redis.conf" ]