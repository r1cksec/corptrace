#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter urlscan.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} 'companyName' outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains from urlscan.io"
    exit 1
fi

companyNameOld=${1}
# add * to company name for wildcard search
companyName=$(echo "*${1}*" | sed 's/ /*/g')
firstCompanyName=$(echo "${companyNameOld}" | cut -d " " -f 1)
outPath=${2}

# search using domain: filter
resultDomain=$(curl -s "https://urlscan.io/api/v1/search/?q=domain:${companyName}*" -H "API-Key: ${apiKey}")
grepResultDomains=$(echo "${resultDomain}" | jq -r ".results[] | .task .domain, .page .domain" | grep -v -E '([0-9]*\.){3}[0-9]*' | awk -F '.' '{print $(NF-1)"."$NF}')

# search using filename: filter
fileName="${firstCompanyName}.*"
resultFile=$(curl -s "https://urlscan.io/api/v1/search/?q=filename:${fileName}" -H "API-Key: ${apiKey}")
grepResultFile=$(echo "${resultFile}" | jq -r ".results[] | .task .domain, .page .domain" | grep -v -E '([0-9]*\.){3}[0-9]*' | awk -F '.' '{print $(NF-1)"."$NF}')

# write json output to file
saveFile="$(echo "${companyNameOld}" | sed 's/[^[:alnum:]]/_/g')"
echo "${resultDomain}" | jq -c > ${outPath}/urlscan-rootdomains-domain-${saveFile}.json
echo "${resultFile}" | jq -c > ${outPath}/urlscan-rootdomains-filename-${saveFile}.json

# print results
echo -e "${grepResultDomains}\n${grepResultDomains}" | sort -u

