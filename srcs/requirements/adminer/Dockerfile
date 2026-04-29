FROM debian:bullseye

RUN apt-get update && apt-get install -y \
	php \
	php-mysql \
	wget

RUN mkdir -p /var/www/adminer
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/adminer/index.php
RUN chown -R www-data:www-data /var/www/adminer

ENTRYPOINT [ "php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer" ]
