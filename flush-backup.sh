#!/bin/sh

##
#
# create backups on /media/wppassport
#
# 

BACKUP_PATH="/media/wppassport"
WD=`pwd`

# check if the backup device is available
if [ ! -d "$BACKUP_PATH" ] 
then
	echo "Error: Backup device not found"
	return 1
fi

echo "Building ~/packages.list …"
dpkg --get-selections | awk '!/deinstall|purge|hold/ {print $1}' > ~/packages.list

echo "Building ~/sources.list …"
find /etc/apt/sources.list* -type f -name '*.list' -exec bash -c 'echo -e "\n## $1 ";grep "^[[:space:]]*[^#[:space:]]" ${1}' _ {} \; > ~/sources.list

##
# Backing up /root
#
if [ -d "$BACKUP_PATH/root" ]
then
        echo "Starting backup /root …"
        rsync -a --progress --delete --delete-excluded /root/  "$BACKUP_PATH/root/"
else
        echo "Error: Could not backup /root as directory $BACKUP_PATH/root does not exist"
fi

##
# Backing up /var/mysql
#
if [ -d "$BACKUP_PATH/var/mysql" ]
then
        echo "Starting backup /var/mysql …"
        rsync -a --progress --delete --delete-excluded /var/mysql/ "$BACKUP_PATH/var/mysql/"
else
        echo "Error: Could not backup /var/mysql as directory $BACKUP_PATH/var/mysql does not exist"
fi

##
# Backing up /etc
#
if [ -d "$BACKUP_PATH/etc" ]
then
        echo "Starting backup /etc …"
        rsync -a --progress --delete --delete-excluded /etc/ "$BACKUP_PATH/etc/"
else
        echo "Error: Could not backup /etc as directory $BACKUP_PATH/etc does not exist"
fi

##
# Backing up /opt
#
if [ -d "$BACKUP_PATH/opt" ]
then
        echo "Starting backup /opt …"
        rsync -a --progress --delete --delete-excluded /opt/ "$BACKUP_PATH/opt/"
else
        echo "Error: Could not backup /opt as directory $BACKUP_PATH/opt does not exist"
fi

##
# Backing up /home/david
#
if [ -d "$BACKUP_PATH/home/david" ]
then
        echo "Starting backup /home/david …"
        # CD to /home as there is the .rsync-filter file
	cd /home
        rsync -aF --progress --delete --delete-excluded david/  "$BACKUP_PATH/home/david/"
else
        echo "Error: Could not backup /home/david as directory $BACKUP_PATH/home/david does not exist"
fi

##
# Backing up /home/heike
#
if [ -d "$BACKUP_PATH/home/heike" ]
then
        echo "Starting backup /home/heike …"
        cd /home
        rsync -aF --progress --delete --delete-excluded heike/ "$BACKUP_PATH/home/heike/"
else
        echo "Error: Could not backup /home/heike as directory $BACKUP_PATH/home/heike does not exist"
fi

##
# Backing up /var/www
#
if [ -d "$BACKUP_PATH/var/www" ]
then
	echo "Starting backup /var/www …"
	cd /var/www
	rsync -aF --progress --delete --delete-excluded ./ "$BACKUP_PATH/var/www/"
else
	echo "Error: Could not backup /var/www as directory $BACKUP_PATH/var/www does not exist"
fi

cd "$WD"
return 0
