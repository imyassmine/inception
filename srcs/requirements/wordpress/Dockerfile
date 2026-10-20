FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	php-fpm php-mysql mariadb-client ca-certificates curl \
	&& rm -rf /var/lib/apt/lists/* \
	&& sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/8.2/fpm/pool.d/www.conf \
	&& curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp \
	&& mkdir -p /var/www/html

WORKDIR /var/www/html
COPY tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh

ENTRYPOINT ["init-wordpress.sh"]
