#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter urlscan.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomain from urlscan.io"
    exit 1
fi

domain=${1}
outPath=${2}

# search using domain: filter
result=$(curl -s "https://urlscan.io/api/v1/search/?q=domain:${domain}" -H "API-Key: ${apiKey}")
printResult=$(echo "${result}" | jq -r ".results[] | .task .domain, .page .domain" | grep -v -E '([0-9]*\.){3}[0-9]*' | awk -F '.' '{print $(NF-1)"."$NF}' | sort -u)

# write json output to file
saveFile="$(echo "${domain}" | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/urlscan-subdomains-${saveFile}.json

# print results
echo "${printResult}"

