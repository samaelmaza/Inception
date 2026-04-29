#!/bin/bash

if ! id "sam_ftp" &>/dev/null; then
	useradd -d /var/www/html sam_ftp
	echo "sam_ftp:sam123" | chpasswd
	echo "FTP User created!"
fi
chown -R sam_ftp:sam_ftp /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
