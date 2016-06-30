#!/usr/bin/env bash

# Force scrict variable handling
set -u

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

##
# Validates a string to be not empty or containing spaces
#
# @param value
# @param var_name 
# 
validate()
{

        if [[ '' == "$1" ]]; then
                echo "$2 must not be empty"
                exit 1
        fi

        if [[ $1 =~ ( ) ]]; then
                echo "$2 must not contain spaces"
                exit 1
        fi
}


echo "Project handle?"
read HANDLE
validate "$HANDLE" "Handle"

echo "Project alias (leave empty to use handle)?"
read ALIAS
if [[ '' != "$ALIAS" ]]; then
	validate "$ALIAS" "Alias"
else
	ALIAS=$HANDLE
fi

echo "Project path (document root)?"
read DOCROOT
validate "$DOCROOT" "Document root"

echo "Hostname?"
read HOSTNAME
validate "$HOSTNAME" "Hostname"

echo "MySQL Handle (leave empty to skip MySQL setup)?"
read MYSQL_HANDLE
if [[ '' != "$MYSQL_HANDLE" ]]; then
	validate "$MYSQL_HANDLE" "MySQL handle"
fi

# Create document root
if [[ ! -d "$DOCROOT" ]]; then
	mkdir -pv "$DOCROOT"
fi

# Copy VHOST config template
TMP_CONF_FILE="$CURRENT_DIR/templates/$HANDLE.conf"
VHOST_CONF_FILE="/etc/apache2/sites-available/$HANDLE.conf"
TEMPLATE="$CURRENT_DIR/templates/vhost.conf"

if [[ -f "$VHOST_CONF_FILE" ]]; then
	echo "Error: VHost config file already exists: $VHOST_CONF_FILE"
	exit 1
fi

cp "$TEMPLATE" "$TMP_CONF_FILE"

# Replace placeholder in temprary config file
sed -i "s~%HOSTNAME%~$HOSTNAME~g" "$TMP_CONF_FILE"
sed -i "s~%DOCROOT%~$DOCROOT~g" "$TMP_CONF_FILE"
sed -i "s~%HANDLE%~$HANDLE~g" "$TMP_CONF_FILE"

# Move temp file to vhost conf file and reload apache2
mv -v "$TMP_CONF_FILE" "$VHOST_CONF_FILE"
a2ensite "$VHOST_CONF_FILE"
service apache2 reload

printf "<h1>It works</h1>" > "$DOCROOT/index.html"
touch "$DOCROOT/.htaccess"

if [[ '' == "$MYSQL_HANDLE" ]]; then
	exit 0
fi

# Create MySQL db
DB_CONF_FILE="$DOCROOT/.my.cnf"
if [[ -f "$DB_CONF_FILE" ]]; then
	exit 0
fi

echo "MySQL password for root?"
read -s MYSQL_PW

# Exit when database already exists
DB_EXISTS=$(mysql -u root -p"$MYSQL_PW" -e "SHOW DATABASES LIKE '$MYSQL_HANDLE'")
if [[ '' != "$DB_EXISTS" ]];then
	echo "Database $MYSQL_HANDLE already exist"
	exit 1
fi

# Create database
mysql -u root -p"$MYSQL_PW" -e "CREATE DATABASE $MYSQL_HANDLE"

# Create user
MYSQL_USER_PW=$(pwgen -s 20 1)

mysql -u root -p"$MYSQL_PW" -e "CREATE USER '$MYSQL_HANDLE'@'localhost' identified by '$MYSQL_USER_PW'"
mysql -u root -p"$MYSQL_PW" -e "GRANT ALL PRIVILEGES ON $MYSQL_HANDLE.* TO '$MYSQL_HANDLE'@'localhost'"

# Write credentials to file
echo "User: $MYSQL_HANDLE" >> "$DB_CONF_FILE"
echo "Database: $MYSQL_HANDLE" >> "$DB_CONF_FILE"
echo "Password: $MYSQL_USER_PW" >> "$DB_CONF_FILE"
