#!/usr/bin/env bash

# Wrapper for WP-CLI commands that should apply to all sites in a multisite

set -euo pipefail

for URL in $(wp site list --field=url); do 
	echo "Running command for $URL"
	wp "$@" --url="$URL" 
done
