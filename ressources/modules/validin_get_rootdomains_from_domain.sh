#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter validin.com ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains, nameserver and reverse ip addresses from validin.com"
    exit 1
fi

domain=${1}
outPath=${2}

result=$(curl -s -H "Authorization: BEARER ${apiKey}" "https://app.validin.com/api/axon/domain/dns/history/${domain}")
ips=$(echo "${result}" | jq -r '.records .A[] | "\(.value) ; \(.first_seen | strftime("%Y-%m-%d")) ; \(.last_seen | strftime("%Y-%m-%d"))"' | sort -t ';' -k3 -r)

firstIp=$(echo "${ips}" | head -n 1 | awk -F " ; " '{print $1}')
historyIp=$(curl -s -H "Authorization: BEARER ${apiKey}" "https://app.validin.com/api/axon/ip/dns/history/$firstIp")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
reverseIpResult="${outPath}/validin-dns-history-timestamps-${saveFile}.csv"

echo "${result}" | jq -c > ${outPath}/validin-rootdomains-dns-history-${saveFile}.json
echo "${historyIp}" | jq -c > ${outPath}/validin-rootdomains-ip-history-${saveFile}.json

echo "Reverse IPs for ${1}:" > ${reverseIpResult}
echo "${ips}" >> ${reverseIpResult}
echo "" >> ${reverseIpResult}

echo "Domain history of ${firstIp}:" >> ${reverseIpResult}
echo "${historyIp}" | jq -r '.records .A[] | "\(.value) ; \(.first_seen | strftime("%Y-%m-%d")) ; \(.last_seen | strftime("%Y-%m-%d"))"' | sort >> ${reverseIpResult}

# print results
echo "${historyIp}" | jq -r '.records .A[] .value' | awk -F '.' '{print $(NF-1)"."$NF}' | sort -u

