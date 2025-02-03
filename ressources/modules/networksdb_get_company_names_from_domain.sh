#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter networksdb.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve company names from networksdb.io"
    exit 1
fi

domain=${1}
outPath=${2}

result=$(curl -s -H "X-Api-Key: ${apiKey}" "https://networksdb.io/api/org-search" -d search="${domain}")
companies=$(echo "${result}" | jq -r '.results[] .organisation')

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c  > ${outPath}/networksdb-company-${saveFile}.json

# print results
echo "${companies}"

