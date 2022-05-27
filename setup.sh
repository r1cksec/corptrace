#!/bin/bash

pathToScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

sed -i "s|REPLACEME|${pathToScriptDir}|g" "${pathToScriptDir}/modules.json"

echo "Please enter full path to driver binary for selenium:"
read path
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/get-mails"
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/north-scraper"

echo "Done"

