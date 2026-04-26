FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt \
	-subj "/C=SP/ST=Madrid/L=Madrid/O=42/OU=Inception/CN=sreffers.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-available/default

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
