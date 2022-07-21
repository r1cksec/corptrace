#!/bin/bash

pathToScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

sed -i "s|REPLACEME|${pathToScriptDir}|g" "${pathToScriptDir}/modules.json"

echo "Please enter full path to chromedriver binary for selenium:"
read path
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/get-mails"
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/get-netblocks"
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/north-scraper"
sed -i "s|REPLACEMEDRIVER|${path}|g" "${pathToScriptDir}/scripts/search-google"

echo "Done"

