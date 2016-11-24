#!/usr/bin/env bash

# create backups on /media/david/wppassport/1404

# force strict variable handling (declaration)
set -u

BACKUP_DIR="/media/david/wppassport/1404"
CURRENT_WD=$(pwd)
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
MYSQL_PASSWD=""

##
# @param $1 a variable reference to read the password in
#
read_pw_into()
{
	TMP_PASSWD=''
	echo  "Insert MySQL Password for user 'root'@'localhost':"
	read -s TMP_PASSWD
	eval "$1=\"$TMP_PASSWD\""
	unset TMP_PASSWD
}

read_pw_into MYSQL_PASSWD

# check if the backup device is available
if [[ ! -d "$BACKUP_DIR" ]]; then
	echo "Error: Backup device not found"
	exit 1
fi

if [[ ! -d ~/bak ]]; then
	echo "Creating ~/bak directory"
	mkdir ~/bak
fi

echo "Building ~/packages.list …"
dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > ~/bak/packages.list

echo "Building ~/sources.list …"
find /etc/apt/sources.list* -type f -name '*.list' \
	-exec bash -c "echo -e \"\n## \$1 \";grep \"^[[:space:]]*[^#[:space:]]\" \${1}" _ {} \; \
	> ~/bak/sources.list

##
# Backing up /root
#
if [[ -d "$BACKUP_DIR/root" ]]; then
    echo "Start backup /root …"
    rsync -a /root/  "$BACKUP_DIR/root/"
else
    echo "Error: Could not backup /root as directory $BACKUP_DIR/root does not exist"
fi

##
# Backing up /var/mysql
#
if [[ ! -d "$BACKUP_DIR/mysql" ]]; then
    echo "Create backup directory /mysql …"
    mkdir "$BACKUP_DIR/mysql"
fi

if [[ -f "$CURRENT_DIR/mysql/dump-all.sh" ]]; then
    cd "$CURRENT_DIR"
    ./mysql/dump-all.sh -u root -h localhost  -p "$MYSQL_PASSWD" -g "$BACKUP_DIR/mysql"
else
    echo "MySQL dump script is not available. Skip …"
fi

if [[ -f "$CURRENT_DIR/mysql/dump-grants.sh" ]]; then
	cd "$CURRENT_DIR"
	./mysql/dump-grants.sh -u root -h localhost -p "$MYSQL_PASSWD" -g "$BACKUP_DIR/mysql/mysql_grants.sql"
else
	echo "MySQL dump grant script is not available. Skip …"
fi

##
# Backing up /etc
#
if [[ -d "$BACKUP_DIR/etc" ]]; then
    echo "Start backup /etc …"
    rsync -a /etc/ "$BACKUP_DIR/etc/"
else
    echo "Error: Could not backup /etc as directory $BACKUP_DIR/etc does not exist"
fi

##
# Backing up /opt
#
if [[ -d "$BACKUP_DIR/opt" ]]; then
    echo "Start backup /opt …"
    rsync -a /opt/ "$BACKUP_DIR/opt/"
else
    echo "Error: Could not backup /opt as directory $BACKUP_DIR/opt does not exist"
fi

##
# Backing up /home/david
#
if [[ -d "$BACKUP_DIR/home/david" ]]; then
    echo "Start backup /home/david …"
    # CD to /home as there is the .rsync-filter file
    cd /home
    rsync -aF david/  "$BACKUP_DIR/home/david/"
else
    echo "Error: Could not backup /home/david as directory $BACKUP_DIR/home/david does not exist"
fi


##
# Backing up /var/www
#
if [[ -d "$BACKUP_DIR/var/www" ]]; then
    echo "Start backup /var/www …"
    cd /var/www
    rsync -aF ./ "$BACKUP_DIR/var/www/"
else
    echo "Error: Could not backup /var/www as directory $BACKUP_DIR/var/www does not exist"
fi

cd "$CURRENT_WD"
