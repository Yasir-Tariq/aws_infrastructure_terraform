#!/bin/bash
set -x
sleep 1m
apt-get update -y
apt-get upgrade -y
apt install mysql-server -y
apt install php -y
apt install php-mysql -y
apt install awscli -y
aws s3 cp s3://yasirassigns3bucketneww/app.init.tar.gz .
cd ~
cd ..
mv app.init.tar.gz ~/
cd ~
tar -zxvf app.init.tar.gz -C ~/
cd /etc/mysql/mysql.conf.d
sed -i -e 's/bind/#bind/1' mysqld.cnf
cd ~
mysql -u root < init.sql
mysql -u root << MYSQL_SCRIPT
CREATE USER 'mydbinstance'@'%' IDENTIFIED BY 'mydbinstance';
GRANT ALL PRIVILEGES ON *.* TO 'mydbinstance'@'%';
FLUSH PRIVILEGES;
exit;
MYSQL_SCRIPT
/etc/init.d/mysql restart
