#!/bin/bash

if [ ${#} -ne 4 ]
then
    echo "usage: ${0} domain outputDirectory apiKeyTa apiKeyTs"
    echo "Run curl command on tomba.io and retrieve social media links and email addresses"
    exit 1
fi

domain=${1}
outPath=${2}
apiKeyTa=${3}
apiKeyTs=${4}
result=$(curl -s --request GET --url "https://api.tomba.io/v1/domain-search?domain=${domain}" --header "X-Tomba-Key: ${apiKeyTa}" --header "X-Tomba-Secret: ${apiKeyTs}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
seFile="${outPath}/tomba-social-media-${saveFile}.txt"
echo "${result}" | jq -c > ${outPath}/tomba-${saveFile}.json

echo "E-Mails ; Phone" > ${seFile}
echo "${result}" | jq -r '.data .emails[] | "\(.email) ; \(.phone_number)"' >> ${seFile}
echo "" >> ${seFile}
echo "Social Media:" >> ${seFile}
echo "${result}" | jq -r '.data.organization | select(.social_links != null) | .social_links | to_entries[] | select(.value | type == "string" and startswith("http")) | .value' >> ${seFile}

# print results
echo "${result}" | jq -r '.data .emails[] | .email'

