#!/bin/bash

set -u

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
