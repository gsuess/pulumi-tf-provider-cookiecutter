#!/usr/bin/env bash

set -e

defaultConfig=/home/cookiecutter/cookiecutter.json
config=/provider/config.json

# Read the contents of the JSON files into variables
defaultConfigContent=$(cat "$defaultConfig")
configContent=$(cat "$config")

# Merge the two JSON objects into a new merged object
merged=$(jq -n --argjson defaultConfig "$defaultConfigContent" --argjson config "$configContent" '$defaultConfig + $config')

# Output the merged JSON object
echo "$merged" > $defaultConfig

cat $defaultConfig

cookiecutter -f /home/cookiecutter -o /provider $@