#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter onyphe.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains from onyphe.io"
    exit 1
fi

domain=${1}
outPath=${2}

# get ip from domain
ip=$(host "${domain}" | grep "has address" | awk -F " " '{print $4}' | head -n 1)

# search for domains using the same ip address
result=$(curl -s -H "Content-Type: application/json" -H "Authorization: bearer ${apiKey}" "https://www.onyphe.io/api/v2/search/?q=category:resolver+ip:${ip}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
domainHistory="${outPath}/onyph-domain-history-${saveFile}.txt"

echo "${result}" | jq -c > ${outPath}/onyph-resolve-ip-${saveFile}.json

echo "Rootdomains resolving to ${ip}:" > ${domainHistory}
echo "${result}" | jq -r '.results[] | select(.domain != null) | .domain, .hostname' | grep -v "\[\|\]" | sed 's/"\| //g' | awk -F '.' '{print $(NF-1) "." $NF}' | sort -u >> ${domainHistory}

# print results
echo "${result}" | jq -r '.results[] | select(.domain != null) | .domain, .hostname' | grep -v "\[\|\]" | sed 's/"\| //g' | awk -F '.' '{print $(NF-1) "." $NF}' | sort -u

