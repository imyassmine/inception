#!/bin/bash
set -e

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

if [ ! -d /var/lib/mysql/mysql ] || [ ! -f /var/lib/mysql/.initialized ]; then
	rm -rf /var/lib/mysql/*
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
	pid=$!

	for _ in $(seq 1 30); do
		mysqladmin ping --silent && break
		sleep 1
	done
	mysqladmin ping --silent

	mysql -uroot <<-EOF
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		DELETE FROM mysql.user WHERE User='';
		DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test\\_%';
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
		DROP USER IF EXISTS '${MYSQL_USER}'@'%';
		CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOF

	mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
	wait "$pid"
	touch /var/lib/mysql/.initialized
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql --console
