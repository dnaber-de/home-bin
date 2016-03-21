#!/bin/bash

set -u

## Nummeric array
declare -a LIST=(
	"one"
	"two"
	"three"
)

## access
echo ${LIST[*]} # one two three
echo ${LIST[1]} # two

LIST[0]='three' # replaces 'one' with 'three'
unset LIST[2] # unsets 'three'

## iteration
for ELEMENT in ${LIST[@]};do
	echo $ELEMENT
done


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
