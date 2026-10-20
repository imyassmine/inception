#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl
if [ ! -f "/etc/nginx/ssl/${DOMAIN_NAME}.crt" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout "/etc/nginx/ssl/${DOMAIN_NAME}.key" \
		-out "/etc/nginx/ssl/${DOMAIN_NAME}.crt" \
		-subj "/C=FR/ST=IDF/L=Paris/O=42/CN=${DOMAIN_NAME}"
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -t
exec nginx -g 'daemon off;'
