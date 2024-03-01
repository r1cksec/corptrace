#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter grayhatwarfare.com ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} 'companyName' outputDirectory [apiKey]"
    echo "Run curl command and retrieve buckets from grayhatwarfare.com"
    exit 1
fi

# use only first part of company name for search
company=$(${1} | cut -d " " -f 1)
outPath=${2}

result=$(curl -s --request GET --url "https://buckets.grayhatwarfare.com/api/v2/files?keywords=${company}&start=0&limit=1000" --header "Authorization: Bearer ${apiKey}")

# write json output to file
saveFile="$(echo ${1} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c  > ${outPath}/grayhatwarfare-buckets-${saveFile}.json

echo "Last modified ; Url:"
echo "${result}" | jq -r '.files[] | "\(.lastModified | strftime("%Y-%m-%d")) ; \(.url)"' | sort -n
echo ""

