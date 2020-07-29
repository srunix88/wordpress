#!/bin/bash
# from the guide posted here:
# https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lemp-on-ubuntu-18-04
# Run as root

#Just the raw commands
apt update
apt install nginx
apt install mysql-server

echo "MySQL server install..."
echo "research auth_socket or native password?"
mysql_secure_installation

cat << EOF

if wordpress installs on this system will need to use the root password
you will need to run the following commands to allow native passwords

sudo mysql
SELECT user,authentication_string,plugin,host FROM mysql.user;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
FLUSH PRIVILEGES;
SELECT user,authentication_string,plugin,host FROM mysql.user;
exit

Check with 
mysql -u root -p

EOF

add-apt-repository universe
apt install php-fpm php-mysql

cat << EOF

When setting up sites, you need to set up nginx to use the php processor
Sample:

server {
        listen 80;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name example.com;

        location / {
                try_files $uri $uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}

test with 

  nginx -t

systemctl reload nginx

EOF

cat << EOF > /var/www/html/info.php

<?php
phpinfo();

EOF
