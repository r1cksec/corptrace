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
result=$(curl -s -X GET "https://api.zoomeye.hk/domain/search?q=${domain}" -H "API-KEY:${apiKey}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/zoomeye-rootdomains-${saveFile}.json

echo "${result}" | jq -r ".list[] .name" | awk -F '.' '{print $(NF-1)"."$NF}' | tr '[:upper:]' '[:lower:]' | sort -u

