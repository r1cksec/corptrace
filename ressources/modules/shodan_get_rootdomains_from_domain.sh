#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter shodan.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains from shodan.io"
    exit 1
fi

domain=${1}
outPath=${2}

resultHostname=$(curl -s "https://api.shodan.io/shodan/host/search?key=${apiKey}&query=hostname:${domain}")
iconHash=$(echo "https://${domain}" | favfreak --shodan | grep "\[DORK\]" | awk -F "http.favicon.hash:" '{print $2}' )
resultIcon=$(curl -s "https://api.shodan.io/shodan/host/search?key=${apiKey}&query=http.favicon.hash:${iconHash}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
rootDomainResults=" ${outPath}/shodan-results.txt"
echo "${resultHostname}" | jq -c  > ${outPath}/shodan-rootdomains-hostname-${saveFile}.json
echo "${resultIcon}" | jq -c  > ${outPath}/shodan-rootdomains-favicon-${saveFile}.json

echo "Domains and hostnames:" > ${rootDomainResults}
echo "${resultHostname}" | jq -r '.matches[] | .domains[], .hostnames[], .http.host | select(. != null)' | grep -v -E '([0-9]*\.){3}[0-9]*' | grep -v ":" | awk -F '.' '{print $(NF-1)"."$NF}' | sort -u >> ${rootDomainResults}
echo "" >> ${rootDomainResults}

echo "Hosts using the same favicon:" >> ${rootDomainResults}
echo "${resultIcon}" | jq -r ".matches[] | .domains[], .hostnames[], .http .host" >> ${rootDomainResults}
echo "" >> ${rootDomainResults}

# print results
grep -v "Domains and hostnames:\|Hosts using the same favicon:" ${rootDomainResults} | sort -u 

