FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php7.4-fpm \
	php-mysql \
	php-redis \
	mariadb-client \
	wget
RUN mkdir -p /run/php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT [ "/usr/local/bin/setup.sh" ]
