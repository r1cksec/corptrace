#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter hunter.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command on hunter.io and retrieve social media links and email addresses"
    exit 1
fi

domain=${1}
outPath=${2}
result=$(curl -s "https://api.hunter.io/v2/domain-search?domain=${domain}&api_key=${apiKey}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
seFile="${outPath}/hunter-se-${saveFile}.txt"
echo "${result}" | jq -c > ${outPath}/hunter-${saveFile}.json

echo "E-Mails:" > ${seFile}
echo "${result}" | jq -r '.data.emails[].value' >> ${seFile}
echo "" >> ${seFile}
echo "Social Media:" >> ${seFile}
echo "${result}" | jq -r '.data | .twitter, .facebook, .linkedin, .instagram, .youtube' | sort -u | grep -v "null" >> ${seFile}

# print results
echo "${result}" | jq -r '.data.emails[].value'

