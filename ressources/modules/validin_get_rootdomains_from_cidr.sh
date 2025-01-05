#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter validin.com ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} ipRangeCidr outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains for given IP range in CIDR notation from validin.com"
    exit 1
fi

cidr=${1}
outPath=${2}
result=$(curl -s -H "Authorization: BEARER ${apiKey}" "https://app.validin.com/api/axon/ip/dns/history/${cidr}")

# write json output to file
saveFile="$(echo ${cidr} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/validin-rootdomains-cidr-${saveFile}.json
timestampFile="${outPath}/validin-rootdomains-timestamps-${saveFile}.csv"
echo "Domain history of ${cidr}:" > ${timestampFile}
echo "${result}" | jq -r '.records .A[] | "\(.value) ; \(.first_seen | strftime("%Y-%m-%d")) ; \(.last_seen | strftime("%Y-%m-%d"))"' | sort -t ';' -k 3 -r >> ${timestampFile}

echo "${result}" | jq -r '.records .A[] .value' | awk -F '.' '{print $(NF-1)"."$NF}' | sort -u

