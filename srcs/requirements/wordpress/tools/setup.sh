#!/bin/bash

cd /var/www/html

if [ ! -f wp-config.php ]; then
	echo "Wordpress installation"
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	wp core download --allow-root

	wp config create --allow-root \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$(cat /run/secrets/db_password) \
		--dbhost=mariadb

	wp core install --allow-root \
		--url=$DOMAIN_NAME \
		--title="Inception" \
		--admin_user=$WP_ADMIN_USER \
		--admin_password=$(cat /run/secrets/wp_admin_password) \
		--admin_email=$WP_ADMIN_EMAIL

	wp user create --allow-root "second_user" "second_user@gmail.com" \
		--role=author \
		--user_pass="user123456"

	wp theme install astra --activate --allow-root

	wp config set WP_REDIS_HOST redis --allow-root
	wp config set WP_REDIS_PORT 6379 --raw --allow-root
	wp config set WP_CACHE true --raw --allow-root
	wp plugin install redis-cache --activate --allow-root
	wp redis enable --allow-root

	chown -R www-data:www-data /var/www/html

else
	echo "Wordpress already installed"
fi

exec /usr/sbin/php-fpm7.4 -F
