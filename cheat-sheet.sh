#!/usr/bin/env bash

####################
# BASH CHEAT SHEET #
####################

# force strict variable handling
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

# load variables from .env file
set -a
source .env
set +a 

#clears the screen
clear

# see https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
CURRENT_DIRECTORY=$(dirname "$(readlink -f "${0}")")

## Enable debugging output
# Checks if a variable is set (otherwise set -u would make this fail)
# see https://stackoverflow.com/a/13864829/2169046
if [[ ! -z "${DEPLOY_DEBUG+x}" ]]; then
    set -x
fi

# system variables
# allways upper case
# e.g. $USER
#
# Special system vars
#
#    $?
#    stores the return code of the last command
# e.g.
# $ rm unknownfile
# $ echo $? -> 1
#
# 0 means "no error"
#
#    $*
#    $@
#    stores all arguments passed to the script
#
#    $#
#        number of given arguments
#
#    $0
#        name of the script
#
#    $1…n
#        value of the n-th argument
#

# variable declaration
x=6
y=3
z=$(expr $x + $y)
date=$(date)


echo "Sum of $x and $y is $z"
echo "Today is $date"

# get user input
#echo "Input something:"
#read usr_input
#echo "You typed \"$usr_input\""

#echo "Arguments passed to this script: $#"
#echo "Script name is: $0"
#echo "First argument: $1"

# conditional stuff
if [[ -d "/media/wppassport" ]]; then

	echo 'Directory exists'
else
	echo 'Directory does not exist'
fi

if [[ $USER != "root" ]]; then
	echo 'you are not root'
else
	echo 'you are root'
fi

## functions

###
 # do sth
 #
 # @arg str $1 Defines the foo
 # @arg str $2
 # @return void
 #
myfunction()
{
	if [[ $# -eq 2 ]]; then
		echo "Argument 1 is: $1"
		echo "Argument 2 is: $2"
	else
		echo "Missing Arguments for function $0"
	fi

	return
}
myfunction ~ -bar

# show diffs of two directories in VIM for colored output
diff -u <(ls -A1 dir1/) <(ls -A1 dir2/) | vim -R -

# run find and execute command on each resulting file
# see https://unix.stackexchange.com/a/12904/131049
find . -type f -exec CMD {} + #{} gets substituted with results, + means one CMD call for all results
find . -type f -exec CMD {} \; # ; means one CMD call per result

# parallel execution of commands in a loop
# see https://unix.stackexchange.com/a/216475/131049
N=4
i=0

for URL in $(wp site list --field=url ); do
   ((i=i%N)); ((i++==0)) && wait
   wp "$@" --url="$URL" &
done
wait

## UTF-8 multibyte sequence
# +-------------------------------------+--------------------------------+
# | 0xxxxxxx                            | ASCII-Zeichen                  |
# | 110xxxxx 10xxxxxx                   | Unicode U+00080 bis U+007ff    |
# | 1110xxxx 10xxxxxx 10xxxxxx          | Unicode U+00800 bis U+0ffff    |
# | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx | Unicode U+10000 bis U+1ffff    |
# +-------------------------------------+--------------------------------+
##

## looping over each line in a file
## https://unix.stackexchange.com/a/580545/131049
while IFS='' read -r LINE || [ -n "${LINE}" ]; do
    echo "processing line: ${LINE}"
done < /path/to/input/file.txt


##
#  using argument of last command in shell history
# https://unix.stackexchange.com/q/271659/131049

# $_ expands to the last argument whereas 
# !$ expands to the last word of the last command in history

exit 0
