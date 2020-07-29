#!/bin/bash
# basic steps for installing the latest WP
mkdir /tmp/wpdownload
cd /tmp/wpdownload
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php

SITEROOT=/var/www/html

cp -a /tmp/wpdownload/wordpress/. $SITEROOT
chown -R www-data:www-data $SITEROOT

echo "Add these to your wp-config.php file"
curl -s https://api.wordpress.org/secret-key/1.1/salt/

echo "modify the DB_NAME, DB_USER and DB_PASSWORD values from your database setup step"
echo "set define('FS_METHOD', 'direct');"

# Common php variables to change
