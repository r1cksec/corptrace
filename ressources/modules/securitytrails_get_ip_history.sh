#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter securitytrails.com ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve ipv4 history of given domain from securitytrails.com"
    exit 1
fi

domain=${1}
outPath=${2}
result=$(curl -s --request GET --url "https://api.securitytrails.com/v1/history/${domain}/dns/a" --header "accept: application/json" --header "APIKEY: ${apiKey}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/securitytrails-ip-history-${saveFile}.json

echo "IPv4 history of ${domain}:"
echo "${result}" | jq -r '.records[] | "\(.first_seen) ; \(.last_seen) ; \(.values[] | .ip)"'

