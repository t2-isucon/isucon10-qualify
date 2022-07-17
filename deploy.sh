#!/bin/bash

# source $HOME/.bash_profile $HOME/.bashrc

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

echo 'Copy sql file...'
sudo cp -r "$DIR/webapp/myql/db" /home/isucon/webapp/mysql/db
echo 'Copied sql file!'

echo 'Updating config file...'
# env
sudo cp "$DIR/env.sh" /home/isucon/env.sh

# nginx
sudo cp "$DIR/nginx/nginx.conf" /etc/nginx/nginx.conf
sudo cp "$DIR/nginx/isuumo.conf" /etc/nginx/sites-enabled/isuumo.conf

# mysql
sudo cp "$DIR/mysql/my.cnf" /etc/mysql/conf.d/my.cnf
sudo cp "$DIR/mysql/mysqld.cnf" /etc/mysql/mysql.conf.d/mysqld.cnf
echo 'Updated config file!'

echo 'Restarting Go...'
sudo systemctl stop isuumo.go.service
cd $DIR/webapp/go/
/home/isucon/local/go/bin/go build -o isuumo
cp isuumo /home/isucon/webapp/go/
cd $DIR
sudo systemctl restart isuumo.go.service
echo 'Restarted!'

echo 'Restarting services...'
sudo systemctl restart mysql.service
sudo systemctl restart nginx.service
echo 'Restarted!'

echo 'Rotating files'
sudo bash -c 'cp /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%s) && echo > /var/log/nginx/access.log'
sudo -u mysql bash -c 'test -f /var/log/mysql-slow.log && cp /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$(date +%s) && echo > /tmp/mysql-slow.sql'
echo 'Rotated!'