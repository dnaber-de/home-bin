#!/usr/bin/env bash

##
# Dump all mysql databases at once
#

# force strict variable handling (declaration)
set -u


##
# Print help message
#
dadb_help()
{
	echo "Dump all mysql content databases

USAGE
	sh dump-all-databases.sh [OPTIONS] DIRECTORY

EXAMPLE
	sh dump-all-databases.sh -u my_user -h mysql.host.tld ~/backup/mysql

OPTIONS
	-u,--user DB User for the mysqldump command (should have privileges to all tables), default to 'root'

	-h,--host DB Host for the mysqldump command, default to 'localhost'

	-p,--password
	          DB Password. Will be prompted if not specified.

	-g        Gzip the resulting files

	--help    Print this help message"
}

if [[ $# -eq 0 ]]
then
	dadb_help
	exit 1;
fi

##
# Declare variables used by the script
#
dadb_declare_vars()
{
	DADB_HELP=""
	DADB_USER=""
	DADB_HOST=""
	DADB_DIR=""
	DADB_ERROR=false
	DADB_MSG=""
	DADB_GZIP=false
	DADB_PASSWD=""
}
dadb_declare_vars

##
# Unset script variables
#
dadb_unset_vars()
{
	unset DADB_HELP
	unset DADB_USER
	unset DADB_HOST
	unset DADB_DIR
	unset DADB_ERROR
	unset DADB_MSG
	unset DADB_GZIP
	unset DADB_PASSWD
}

##
# @param $1 a variable reference to read the password in
#
dadb_read_pw_into()
{
	DADB_TMP_PASSWD=''
	echo  "Insert Password:"
	read -s DADB_TMP_PASSWD
	eval "$1=\"$DADB_TMP_PASSWD\""
	unset DADB_TMP_PASSWD
}

##
# The main working horse
#
# @param $1 user
# @param $2 host
# @param $3 dir
# @param $4 gzip
# @param $5 passwd
#
dadb_dump_databases()
{
	local USER="$1"
	local HOST="$2"
	local DIR="$3"
	local GZIP="$4"
	local PASSWD=""
	#local DATE=$(date +%F-%T)

	if [[ -z $5 ]]; then
		dadb_read_pw_into PASSWD
	else
		PASSWD="$5"
	fi

	local SYSTEM_TABLES=(
		"information_schema"
		"performance_schema"
		"mysql"
	)


	local DATABASES=$(mysql -u "$USER" -h "$HOST" -p"$PASSWD" -Bse "SHOW DATABASES;")

	for DADB_DB in $DATABASES
	do
		if [[ "$DADB_DB" == 'information_schema' || "$DADB_DB" == 'performance_schema' || "$DADB_DB" == 'mysql' ]]
		then
			echo "Info: Skip database $DADB_DB"
			continue
		fi

		local FILE="$DIR/$DADB_DB.sql"
		echo "Dumping $DADB_DB ..."
		mysqldump -u "$USER" -h "$HOST" -p"$PASSWD" "$DADB_DB" > "$FILE"

		if [[ "$GZIP" == 'true' ]]
		then
			echo "Compressing $FILE"
			gzip -f "$FILE"
		fi

	done
	unset DADB_DB
}

# Parsing script arguments
#
# @link http://stackoverflow.com/a/14203146/2169046
#

while [[ $# -gt 0 ]]
do
	DADB_KEY="$1"

	# the last parameter must allways be the target directory
	if [[ $# -eq 1 && ${1:0:1} != '-' ]]
	then
		# trim trailing slash
		DADB_DIR=${1%/}
		break
	fi

	case $DADB_KEY in

		--help)
		DADB_HELP=true
		shift
		;;

		-u|--user)
		DADB_USER="$2"
		shift
		shift
		;;

		-h|--host)
		DADB_HOST="$2"
		shift
		shift
		;;

		-p|--password)
		DADB_PASSWD="$2"
		shift
		shift
		;;

		-g)
		DADB_GZIP=true
		shift
		;;

		*)
		DADB_ERROR=true
		DADB_MSG="Unknown parameter $DADB_KEY\nuse the parameter -h to get help"
		;;
	esac
done
unset DADB_KEY

if [[ $DADB_ERROR == "true" ]]
then
	echo -e "Error: $DADB_MSG"
	dadb_unset_vars
	exit 1
fi

if [[ $DADB_HELP == "true" ]]
then
	dadb_help
	dadb_unset_vars
	exit 0
fi

if [[ -z $DADB_USER ]]
then
	DADB_USER="root"
	echo "No user specified, fall back to 'root'"
fi

if [[ -z $DADB_HOST ]]
then
	DADB_HOST="localhost"
	echo "No host specified, fall back to 'localhost'"
fi

if [[ ! -d $DADB_DIR ]]
then
	echo "Directory '$DADB_DIR' does not exist"
	dadb_unset_vars
	exit 1
fi

dadb_dump_databases "$DADB_USER" "$DADB_HOST" "$DADB_DIR" "$DADB_GZIP" "$DADB_PASSWD"

dadb_unset_vars
