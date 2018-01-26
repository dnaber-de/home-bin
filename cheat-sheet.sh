#
# some scripting test
#

# force strict variable handling
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

#clears the screen
clear

# see https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e
CURRENT_DIRECTORY=$(dirname $(readlink -f "\${0}"))

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

exit 0
