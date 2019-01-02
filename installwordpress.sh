#!/bin/bash
# WordPress Install 
# Ubuntu 16_04 install from scratch
# Run this script as root or with sudo.

DomainsRootHome=/home
WPDIR=public_html
Domain=example.com
USERS="user1 user2 user3 user4"
WP_DB=examplewp
DB_PW=password

if ! host -t a google.com 
then 
cat > /etc/resolv.conf << EOF
domain srunix.net
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
fi

apt-get update 
apt install tasksel
tasksel install lamp-server
### this failed on Ubuntu - need to see if there is a fix.
### also need to set the root password for mysql and secure it.
### TODO
#mysql << EOF
#ALTER USER 'root'@'localhost' IDENTIFIED by 'password';
#EOF


apt install curl

apt install php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

mv wp-cli.phar /usr/local/bin/wp
WordPress_LOCATION='http://wordpress.org/latest.tar.gz'
wget --no-check-certificate $WordPress_LOCATION -O /tmp/wordpress.tar.gz
tar -xz -C /tmp -f /tmp/wordpress.tar.gz
mv /tmp/wordpress /tmp/public_html

useradd -u 555 -g 33 -s /bin/bash -d /home/ncfisher -m ncfisher

for User in $USERS
do
   TARGET=$DomainsRootHome/$User
   mkdir -p $TARGET
   cp -r /tmp/public_html $TARGET
   chown -R www-data:www-data $TARGET
   cd $TARGET/public_html
   mysql << EOF
   create user '${User}wp'@'localhost' IDENTIFIED by 'password';
   create database ${User}wp
   GRANT ALL PRIVILEGES ON ${User}wp TO '${User}wp'@'localhost';
   FLUSH PRIVILEGES;
EOF
   
   sudo -u ncfisher -i -- configwp
   #vhost-setup $Domain $User $TARGET
done

vhost-setup () {
# result will be subdomain.example.com will point to /home/user/public_html
Domain=$1
subdomain=$2
host_dir=$3
# found a nice script that I hope will set these up easily.
wget -O virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
chmod +x virtualhost
bash virtualhost create $subdomain.$Domain $host_dir

}

configwp () {

cd $DomainsRootHome/$User
pwd
wp core config --dbname=${User}wp --dbuser=${User}wp --dbpass=$DB_PW --dbhost=localhost --dbprefix=wp_

}
