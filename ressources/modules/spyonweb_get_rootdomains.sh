#!/bin/bash

if [ ${#} -eq 2 ]
then
    read -p "Enter spyonweb.com ApiKey: " apiKey
elif [ ${#} -eq 3 ]
then
    apiKey=${3}
else
    echo "usage: ${0} domain outputDirectory [apiKey]"
    echo "Run curl command and retrieve rootdomains, google IDs and nameserver ips from spyonweb.com"
    exit 1
fi

domain=${1}
outPath=${2}
result=$(curl -s "https://api.spyonweb.com/v1/domain/${domain}?access_token=${apiKey}")

# write json output to file
saveFile="$(echo ${domain} | sed 's/[^[:alnum:]]/_/g')"
reverseGoogleResults="${outPath}/spyonweb-reverse-googleid-${saveFile}.csv"
reverseIpResults="${outPath}/spyonweb-reverse-ip-${saveFile}.csv"
reverseNsResults="${outPath}/spyonweb-reverse-nameserver-${saveFile}.csv"
echo "${result}" | jq -c > ${outPath}/spyonweb-rootdomains-${saveFile}.json

# quick fix (jq -r 2> /dev/null)
echo "Google Analytics ; Domain ; Timestamp" > ${reverseGoogleResults}
echo "${result}" | (jq -r 'try .result .analytics | to_entries[] | .key as $ua | .value .items | to_entries[] | "\($ua) ; \(.key) ; \(.value)"' 2> /dev/null) >> ${reverseGoogleResults}

echo "IP ; Domain ; Timestamp " > ${reverseIpResults}
echo "${result}" | (jq -r 'try .result .ip | to_entries[] | .key as $ip | .value .items | to_entries[] | "\($ip) ; \(.key) ; \(.value)"' 2> /dev/null) >> ${reverseIpResults}

echo "Nameserver ; Domain ; Timestamp" > ${reverseNsResults}
echo "${result}" | (jq -r '.result .dns_domain | to_entries[] | .key as $ns | .value .items | to_entries[] | "\($ns) ; \(.key) ; \(.value)"' 2> /dev/null) >> ${reverseNsResults}

# print rootdomains
printUa=$(cat ${reverseGoogleResults} | grep -v "Google Analytics ; Domain ; Timestamp" | cut -d ";" -f 2)
printIp=$(cat ${reverseIpResults} | grep -v "IP ; Domain ; Timestamp" | cut -d ";" -f 2)
printNs=$(cat ${reverseNsResults} | grep -v "Nameserver ; Domain ; Timestamp" | cut -d ";" -f 2)
echo -e "${printUa}\n${printIp}\n${printNs}" | sed 's/ //g' | awk -F '.' 'NF >= 2 {print $(NF-1) "." $NF}' | sort -u

