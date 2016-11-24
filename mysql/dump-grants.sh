#!/usr/bin/env bash

##
# Dump all mysql users and grants
#

# force strict variable handling (declaration)
set -u

##
# @param $0 script name
#
print_help()
{
	echo "Exports MySQL user and their grants to a given file

USAGE
	$1 [OPTIONS] FILE

EXAMPLE
	$1 -u my_user -h mysql.host.tld ~/backup/mysql/mysql_grants.sql

ARGUMENTS

	FILE      The file to write the SQL statements in. An existing file will be overwritten.

OPTIONS
	-u,--user DB User for the mysqldump command (should have privileges to all tables), default to 'root'

	-h,--host DB Host for the mysqldump command, default to 'localhost'

	-p,--password
	          DB Password. Will be prompted if not specified.

	-g        Gzip the resulting files

	--help    Print this help message"
}

##
# @param $1 a variable reference to read the password in
#
read_pw_into()
{
	TMP_PASSWD=''
	echo  "Insert Password:"
	read -s TMP_PASSWD
	eval "$1=\"$TMP_PASSWD\""
	unset TMP_PASSWD
}

##
# The main working horse
#
# @param $1 user
# @param $2 host
# @param $3 gzip
# @param $4 file
#
dump_grants()
{
	local USER="$1"
	local HOST="$2"
	local GZIP="$3"
	local FILE="$4"
	local PASSWD=""

	if [[ -z $5 ]]; then
		read_pw_into PASSWD
	else
		PASSWD="$5"
	fi

	local QUERIES=$(mysql -p"$PASSWD" -u"$USER" -h"$HOST" -B -N -e "SELECT DISTINCT CONCAT(
        'SHOW GRANTS FOR \'', user, '\'@\'', host, '\';'
        ) AS query FROM mysql.user WHERE user NOT IN ('root', 'debian-sys-maint')")

	echo "Writing MySQL grants to $FILE"
	mysql -p"$PASSWD" -u"$USER" -h"$HOST" -B -N -e "$QUERIES" |  sed 's/$/;/g' > "$FILE"

	if [[ $GZIP == "true" ]]; then
		echo "Compressing $FILE"
		gzip -f "$FILE"
	fi
}

DB_USER=""
DB_HOST=""
EXPORT_FILE=""
ERROR=false
ERROR_MSG=""
PASSWD=""
GZIP=false
HELP=false

if [[ 0 == "$#" ]]; then
	print_help "$0"
	exit 1
fi

while [[ $# -gt 0 ]]
do
	KEY="$1"
		# the last parameter must always be the target directory
	if [[ $# -eq 1 && ${1:0:1} != '-' ]]
	then
		# trim trailing slash
		EXPORT_FILE="$1"
		break
	fi

	case $KEY in

		--help)
		HELP=true
		shift
		;;

		-u|--user)
		DB_USER="$2"
		shift
		shift
		;;

		-h|--host)
		DB_HOST="$2"
		shift
		shift
		;;

		-p|--password)
		PASSWD="$2"
		shift
		shift
		;;

		-g)
		GZIP=true
		shift
		;;

		*)
		ERROR=true
		ERROR_MSG="Unknown parameter $DADB_KEY\nuse the parameter -h to get help"
		;;
	esac
done

if [[ $ERROR == "true" ]]; then
	echo -e "Error: $ERROR_MSG"
	exit 1
fi

if [[ -z $EXPORT_FILE ]]; then
	echo "No file specified"
	exit 1
fi

if [[ $HELP == "true" ]]; then
	print_help
	exit 0
fi

if [[ -z $DB_USER ]]; then
	DB_USER="root"
	echo "No user specified. Using 'root'"
fi

if [[ -z $DB_HOST ]]; then
	DB_HOST="localhost"
	echo "No host specified. Using 'localhost'"
fi

dump_grants "$DB_USER" "$DB_HOST" "$GZIP" "$EXPORT_FILE" "$PASSWD"

unset PASSWD