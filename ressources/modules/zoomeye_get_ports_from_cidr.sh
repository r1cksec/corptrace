#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter zoomeye.org ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} ipRangeCidr outputDirectory [apiKey]"
    echo "Run curl command on zoomeye.org and retrieve open ports"
    exit 1
fi

cidr=${1}
outPath=${2}
result=$(curl -s -X GET "https://api.zoomeye.org/host/search?query=cidr:${cidr}" -H "API-KEY:${apiKey}")

# write json output to file
saveFile="$(echo ${cidr} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/zoomeye-ports-${saveFile}.json

echo "Open Ports:"
echo "${result}" | jq -r '.matches[] | "\(.ip) ; \(.portinfo .port) ; \(.portinfo .service) ; \(.rdns) ; \(.portinfo | .title)"' | sort -n

