#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter shodan.io ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} 'companyName' outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains from shodan.io"
    exit 1
fi

companyName=${1}
outPath=${2}
result=$(curl -s "https://api.shodan.io/shodan/host/search?key=${apiKey}&query=org:%27${companyName}%27")

# write json output to file
saveFile="$(echo ${companyName} | sed 's/[^[:alnum:]]/_/g')"
echo "${result}" | jq -c > ${outPath}/shodan-rootdomains-${saveFile}.json

echo ""
echo "${result}" | jq -r ".matches[] | .domains[], .hostnames[], .http .host" | grep -v -E '([0-9]*\.){3}[0-9]*' | awk -F '.' '{print $(NF-1)"."$NF}' | sort -u

