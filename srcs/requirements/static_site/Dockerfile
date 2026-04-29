FROM debian:bullseye

RUN apt-get update && apt-get install -y python3

RUN mkdir -p /var/www/static_site
COPY conf/index.html /var/www/static_site

ENTRYPOINT [ "sh", "-c", "cd /var/www/static_site && python3 -m http.server 3000" ]
