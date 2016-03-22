#!/bin/bash

##
# Scripts should always exit on 0 on success or 1 on error

SUCCESS=1
if [[ $SUCCESS == 1 ]]; then
	exit 0
else 
	exit 1
fi

##
# get the response code from another command
#
# $? contains the status of the previous command
#
# @link https://www.linuxjournal.com/magazine/work-shell-handling-errors-and-making-scripts-bulletproof 

mkdir /tmp/foobar
echo "Return status is $?" # == 0

mkdir /tmp/foobar 
echo "Return status is $?" # == 1
