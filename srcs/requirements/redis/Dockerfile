FROM debian:bullseye

RUN apt-get update && apt-get install -y redis-server

RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis/redis.conf

ENTRYPOINT [ "redis-server", "--protected-mode", "no" ]
