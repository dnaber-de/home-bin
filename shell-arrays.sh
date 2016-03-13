#!/bin/bash

set -u

## Nummeric array
LIST=(
	"foo"
	"bar"
	"bazz"
)

## access
echo ${LIST[*]} # foo bar bazz
echo ${LIST[1]} # bar

LIST[0]='bar' # replaces 'foo' with 'bar'
unset LIST[2] # unsets 'bazz'


## declare an associative array
declare -A map
map[foo]="Hello World"
map[bar]="Hallo Welt"

# alternative syntax
declare -A othermap=(
	[foo]="Hello world"
	[bar]="Hallo Welt"
)

## direct access
echo "${map[foo]}"

## iteration

for KEY in "${!othermap[@]}"; do
	echo "key: $KEY"
	echo "value: ${othermap[$KEY]}"
done;
