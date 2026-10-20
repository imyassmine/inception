FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	nginx openssl gettext-base \
	&& rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/init-nginx.sh /usr/local/bin/init-nginx.sh

ENTRYPOINT ["init-nginx.sh"]
