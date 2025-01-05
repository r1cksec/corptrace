#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter shodan.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} ipRangeCidr outputDirectory [apiKey]"
    echo "Run curl command and retrieve open ports from shodan.io"
    exit 1
fi

cidr=${1}
outPath=${2}

result=$(curl -s "https://api.shodan.io/shodan/host/search?key=${apiKey}&query=net:${cidr}")

# write json output to file
saveFile="$(echo ${cidr} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/shodan-ports-cidr-${saveFile}.json

echo "Open Ports:"
echo "${result}" | jq -r '.matches[] | "\(.ip_str) ; \(.port) ; \(.hostnames)" as $entry | .http | "\($entry) ; \(.title) "' | sort -n

