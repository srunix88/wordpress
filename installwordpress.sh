#!/bin/bash
# WordPress Install 
# Ubuntu 16_04 install from scratch
# Run this script as root or with sudo.

### Change the domain name to your domain that you manage in DNS.
### The URL will be a combination of $site.$domain once it is all working
### you can do multiple sites in one set up.... 
### As of 01/10/2019 I am still working out the kinks.
### Also, I write directly to master and am not versioning this yet. Use at your own risk.

DomainsRootHome=/home
WPDIR=public_html
Domain=example.com
SITES="www5"
DB_PW=password

dnsconfig()  {
# initial install of VM on some platforms do not set up DNS - name resolution
if ! host -t a google.com 
then 
cat > /etc/resolv.conf << EOF
domain srunix.net
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
fi
}

install_software() {
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
}

download_wp() {
  if [ ! -f /tmp/public_html/index.php ] 
  then
    WordPress_LOCATION='http://wordpress.org/latest.tar.gz'
    wget --no-check-certificate $WordPress_LOCATION -O /tmp/wordpress.tar.gz
    tar -xz -C /tmp -f /tmp/wordpress.tar.gz
    mv /tmp/wordpress /tmp/public_html
  fi
} 


addshell() {
       	useradd -u 555 -g 33 -s /bin/bash -d /home/ncfisher -m ncfisher
}

vhost-setup () {
# result will be subdomain.example.com will point to /home/user/public_html
Domain=$1
subdomain=$2
host_dir=$3
# found a nice script that I hope will set these up easily.
if [ ! -f virtualhost ]
then
  wget -O virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
  chmod +x virtualhost
fi
bash virtualhost create $subdomain.$Domain $host_dir

}

configwp () {

site=$1
echo "cd $DomainsRootHome/$site/public_html" > /tmp/configwp.sh 
echo "wp core config --dbname=${site}wp --dbuser=${site}wp --dbpass=$DB_PW --dbhost=localhost --dbprefix=wp_" >> /tmp/configwp.sh

}



configure_sites() {
for site in $SITES
do
   TARGET=$DomainsRootHome/$site
   mkdir -p $TARGET
   cp -r /tmp/public_html $TARGET
   chown -R www-data:www-data $TARGET
   cd $TARGET/public_html
   cat /dev/null > /tmp/makeusers.sql
   cat  << EOF >> /tmp/makeusers.sql
create user '${site}wp'@'localhost' IDENTIFIED by 'password';
create database ${site}wp;
GRANT ALL PRIVILEGES ON ${site}wp.* TO '${site}wp'@'localhost';
FLUSH PRIVILEGES;
EOF
   mysql -u root -p < /tmp/makeusers.sql   
   configwp $site 
   sudo -u ncfisher -i -- bash /tmp/configwp.sh
   vhost-setup $Domain $site $TARGET/$WPDIR
done

}

### Note, there are a few bugs when run on some platforms, the commands fail
### If configuring multiple sites, the add_shell should only be run once.
### TODO: put wrappers and conditionals around each.
### TODO: wp commands are failing and the database set up does not work

#dnsconfig
#install_software
download_wp
# add_shell
configure_sites


