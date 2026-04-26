#!/bin/bash
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then

	echo "Maria db's first configuration"
	service mariadb start
	sleep 2

	DB_PWD=$(cat /run/secrets/db_password)
	DB_ROOT_PWD=$(cat /run/secrets/db_root_password)

	mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
	mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PWD}';"
	mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
	mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';"
	mysql -e "FLUSH PRIVILEGES;"

	mysqladmin -u root -p${DB_ROOT_PWD} shutdown
else
	echo "Maria db already exists"
fi

exec mysqld_safe
