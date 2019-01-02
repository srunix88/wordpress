#!/bin/bash
# WordPress Install 
# Ubuntu 16_04 install from scratch
# Run this script as root or with sudo.

DomainsRootHome=/home
WPDIR=public_html
Domain=example.com
WP_USERS="user1 user2 user3 user4"
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
apt install curl

apt install php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

mv wp-cli-phar /usr/local/bin/wp
WordPress_LOCATION='http://wordpress.org/latest.tar.gz'
wget --no-check-certificate $WordPress_LOCATION -O /tmp/wordpress.tar.gz
tar -xz -C /tmp -f /tmp/wordpress.tar.gz

useradd -u 33 -g 33 -s /bin/bash -d /home/ncfisher -m ncfisher

for User in $WP_USERS
do
   TARGET=$DomainsRootHome/$User/$WPDIR
   mkdir -p $TARGET
   cp -r /tmp/wordpress $TARGET
   chown -R www-data:www-data $TARGET
   wp core config --dbname=${User}wp --dbuser=${User}wp --dbpass=$DB_PW --dbhost=localhost --dbprefix=wp_
   vhost-setup $Domain $User $TARGET
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
