#!/usr/bin/env bash

# Force scrict variable handling
set -euo pipefail

if [[ -z ${DEPLOY_DEBUG+x} ]]; then
	set -x
fi

CURRENT_DIR=$(dirname $(readlink -f "${0}"))

##
# Validates a string to be not empty or containing spaces
#
# @param value
# @param var_name
#
validate()
{

	if [[ '' == "${1}" ]]; then
		echo "${2} must not be empty"
		exit 1
	fi

	if [[ ${1} =~ ( ) ]]; then
		echo "${2} must not contain spaces"
		exit 1
	fi
}


echo "Project handle (used as virtual host config file name)?"
read HANDLE
validate "${HANDLE}" "Handle"

echo "Project alias (for ~/.bash_aliases, leave empty to skip alias creation)?"
read ALIAS
if [[ '' != "${ALIAS}" ]]; then
	validate "${ALIAS}" "Alias"
fi

echo "Project path?"
read PROJECT_ROOT
validate "${PROJECT_ROOT}" "Project path"

DOCROOT="${PROJECT_ROOT}/public"

echo "Hostname?"
read PROJECT_HOSTNAME
validate "${PROJECT_HOSTNAME}" "Hostname"

echo "MySQL Handle (leave empty to skip MySQL setup)?"
read MYSQL_HANDLE
if [[ '' != "${MYSQL_HANDLE}" ]]; then
	validate "${MYSQL_HANDLE}" "MySQL handle"
fi

# Create document root
if [[ ! -d "${PROJECT_ROOT}" ]]; then
	mkdir -pv "${PROJECT_ROOT}"
fi

if [[ ! -d "${DOCROOT}" ]]; then
	mkdir -pv "${DOCROOT}"
fi
# Copy .htaccess template to doc-root
cp "${CURRENT_DIR}/templates/.htaccess" "${DOCROOT}/.htaccess"

# Copy VHOST config template
TMP_CONF_FILE="${CURRENT_DIR}/templates/${HANDLE}.conf"
VHOST_CONF_FILE="/etc/apache2/sites-available/${HANDLE}.conf"
VHOST_TEMPLATE="${CURRENT_DIR}/templates/vhost.conf"

if [[ -f "${VHOST_CONF_FILE}" ]]; then
	echo "Error: VHost config file already exists: ${VHOST_CONF_FILE}"
	exit 1
fi

cp "${VHOST_TEMPLATE}" "${TMP_CONF_FILE}"

# Replace placeholder in temporary config file
sed -i "s~%HOSTNAME%~${PROJECT_HOSTNAME}~g" "${TMP_CONF_FILE}"
sed -i "s~%DOCROOT%~${DOCROOT}~g" "${TMP_CONF_FILE}"
sed -i "s~%HANDLE%~${HANDLE}~g" "${TMP_CONF_FILE}"

# Move temp file to vhost conf file and reload apache2
sudo mv -v "${TMP_CONF_FILE}" "${VHOST_CONF_FILE}"
sudo chown root:root "${VHOST_CONF_FILE}"
sudo a2ensite "${HANDLE}.conf"
sudo service apache2 reload

printf "<h1>It works</h1>" > "${DOCROOT}/index.html"
touch "${DOCROOT}/.htaccess"


# Create alias
if [[ '' != "${ALIAS}" ]]; then
	ALIAS_FILE=~/.bash_aliases
	# important to use ' || true' here as grep returns with 1
	# which will lead set -e to terminate immediately
	ALIAS_EXIST=$(grep -c "alias ${ALIAS}=" "${ALIAS_FILE}" || true)
	if [[ "${ALIAS_EXIST}" -eq 0 ]]; then
		echo "alias ${ALIAS}='cd ${PROJECT_ROOT}'" >> "${ALIAS_FILE}"
	else
		echo "Alias already exists. Skip..."
	fi
fi

# Create MySQL db

if [[ '' == "${MYSQL_HANDLE}" ]]; then
	exit 0
fi

DB_CONF_FILE="${PROJECT_ROOT}/.my.cnf"
if [[ -f "${DB_CONF_FILE}" ]]; then
	exit 0
fi

echo "MySQL password for root?"
read -s MYSQL_PW

# Exit when database already exists
DB_EXISTS=$(mysql -u root -p"${MYSQL_PW}" -e "SHOW DATABASES LIKE '${MYSQL_HANDLE}'")
if [[ '' != "${DB_EXISTS}" ]];then
	echo "Database ${MYSQL_HANDLE} already exist"
	exit 1
fi

# Create database
mysql -u root -p"${MYSQL_PW}" -e "CREATE DATABASE ${MYSQL_HANDLE}"

# Create user
MYSQL_USER_PW=$(pwgen -s 20 1)

mysql -u root -p"${MYSQL_PW}" -e "CREATE USER '${MYSQL_HANDLE}'@'localhost' identified by '${MYSQL_USER_PW}'"
mysql -u root -p"${MYSQL_PW}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_HANDLE}.* TO '${MYSQL_HANDLE}'@'localhost'"

# Write credentials to file
echo "User: ${MYSQL_HANDLE}" >> "${DB_CONF_FILE}"
echo "Database: ${MYSQL_HANDLE}" >> "${DB_CONF_FILE}"
echo "Password: ${MYSQL_USER_PW}" >> "${DB_CONF_FILE}"
