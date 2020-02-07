#!/bin/bash
set -x
sleep 1m
apt-get update -y
apt-get upgrade -y
apt install apache2 -y
apt install php -y
apt install php-mysql -y
cd /var/www
rm -r html/
cd
apt install awscli -y
aws s3 cp s3://yasirassigns3bucketneww/app.php.tar.gz .
tar -zxf app.php.tar.gz -C /var/www/
cd
sed -i -e 's/10.0.2.17/${local_ip}/g' /var/www/html/config.php
service apache2 restart