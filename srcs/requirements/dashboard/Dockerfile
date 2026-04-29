FROM debian:bullseye

RUN apt-get update && apt-get install -y python3
COPY conf/server.py /var/www/dashboard/server.py

ENTRYPOINT [ "python3", "/var/www/dashboard/server.py"]
