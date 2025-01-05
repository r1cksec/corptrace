#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter intelx.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve email addresses from intelx.io"
    exit 1
fi

domain=${1}
outPath=${2}

# amount of results may vary
searchId=$(curl -s -X POST -H "Content-Type: application/json" -H "x-key: ${apiKey}" 'https://2.intelx.io/phonebook/search' --data "{\"term\":\"${domain}\",\"lookuplevel\":0,\"maxresults\":1000,\"timeout\":null,\"datefrom\":\"\",\"dateto\":\"\",\"sort\":2,\"media\":0,\"terminate\":[]}" | jq -r .id)
sleep 3
result=$(curl -s -H "x-key: ${apiKey}" "https://2.intelx.io/phonebook/search/result?id=${searchId}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/phonebook-${saveFile}.json

echo "${result}" | jq -r '.selectors[] | select(.selectortypeh == "Email Address") | .selectorvalue'

