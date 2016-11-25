#!/bin/sh

# force strict variable handling (declaration)
set -u

##
# usage
#    dadb_array_contains arr value
# @link http://stackoverflow.com/a/14367368/2169046
dadb_array_contains()
{
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

main()
{

	local array=('foo','bar_baz');

	dadb_array_contains array "foo" && echo "Foo ist drin" || echo "Foo ist nicht drin"
	dadb_array_contains array "bar_baz" && echo "bar_baz ist drin" ||  echo "bar_baz ist nicht drin"
}
main
