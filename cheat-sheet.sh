#
# some scripting test
#

# force strict variable handling
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euo pipefail

#clears the screen
clear

# see https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
CURRENT_DIRECTORY=$(dirname $(readlink -f "${0}"))

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

exit 0
