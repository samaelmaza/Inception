FROM debian:bullseye

RUN apt-get update && apt-get install -y vsftpd
RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

ENTRYPOINT [ "/usr/local/bin/setup.sh" ]
