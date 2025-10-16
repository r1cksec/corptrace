#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter zoomeye.hk ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command on zoomeye.hk and retrieve rootdomains"
    exit 1
fi

domain=${1}
outPath=${2}
encodedQuery=$(echo -n "domain:'${domain}'" | base64 -w 0)
result=$(curl -s -X POST "https://api.zoomeye.ai/v2/search" -d "{\"qbase64\": \"${encodedQuery}\", \"page\": 1}" -H "API-KEY: ${apiKey}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/zoomeye-rootdomains-${saveFile}.json

echo "${result}" | jq -r '.data[] | select(.domain and .domain != "") | .domain' | sort -u

