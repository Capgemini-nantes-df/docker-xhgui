#!/bin/bash

set -e

# render config templates
envtpl /opt/xhprof/xhprof_lib/config.php.tpl
envtpl /etc/apache2/sites-enabled/000-default.conf.tpl

[ -n "$HTTP_AUTH_USER" ] && htpasswd -cb /etc/apache2/htpasswd "$HTTP_AUTH_USER" "$HTTP_AUTH_PASS"

set -eu

mkdir -p "/var/lib/mysql"
chown -R mysql:mysql "/var/lib/mysql"
mysql_install_db --user=mysql

# start mysql in the background while we create user accounts
mysqld_safe &
while ! nc -zv localhost 3306
do
    sleep 1
done

if ! mysql -e 'use xhprof'; then
    # create db and table
    echo "CREATE DATABASE xhprof" | mysql
    mysql xhprof < /tmp/schema.sql

    # disable remote root login
    echo "DELETE FROM user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')" | mysql mysql
    echo "FLUSH PRIVILEGES" | mysql

    # create new user
    echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS'" | mysql xhprof
    echo "GRANT ALL ON xhprof.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'" | mysql xhprof
else
    echo "DATABASE xhprof already exists"
fi

mysqladmin shutdown

supervisord -n
