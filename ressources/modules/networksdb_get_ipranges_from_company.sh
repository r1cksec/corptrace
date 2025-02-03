#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter networksdb.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} 'companyName' outputDirectory [apiKey]"
    echo "Run curl command and retrieve organisations and ip ranges from networksdb.io"
    exit 1
fi

company=${1}
outPath=${2}

resultOrgSearch=$(curl -s -H "X-Api-Key: ${apiKey}" "https://networksdb.io/api/org-search" -d search="${company}")
companyIds=$(echo "${resultOrgSearch}" | jq -r '.results[] .id')

# write json output to file
saveFile="$(echo ${company} | sed 's/[^[:alnum:]]/_/g')"
idFile="${outPath}/networksdb-orgsearch-id-ranges.txt"
echo "${resultOrgSearch}" | jq -c  > ${outPath}/networksdb-orgsearch-${saveFile}.json

# query networksdb for each company id
for id in ${companyIds}
do
    resultIpRanges=$(curl -s -H "X-Api-Key: ${apiKey}" "https://networksdb.io/api/org-networks" -d id="${id}")
    
    # write json output to file
    echo "${resultIpRanges}" | jq -c > ${outPath}/networksdb-ipranges-${id}-${saveFile}.json
    echo "${id}" >> ${idFile}
    echo "${resultIpRanges}" | jq -r '.results[] .cidr' >> ${idFile}
	echo "" >> ${idFile}

    # print results
    echo "${resultIpRanges}" | jq -r '.results[] .cidr' | grep -v "N/A"
done

# quick fix 
exit 0

