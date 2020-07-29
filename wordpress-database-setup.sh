#!/bin/bash
#
# To have multiple sites, set up users and databases for each WP install separately.

DB=site1wpdb
USER=site1user
DBPW=password

echo "How to setup $DB with $USER and password $DBPW"

cat << EOF

sudo mysql
CREATE DATABASE $DB DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON $DB.* TO '$USER'@'localhost' IDENTIFIED BY '$DBPW';
FLUSH PRIVILEGES;
EXIT;


EOF
