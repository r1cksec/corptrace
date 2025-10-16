#!/bin/bash

if [ ${#} -ne 2 ]
then
    echo "usage: ${0} filedomain outputDirectory"
    echo "filedomain: File containing domains, one per line"
    exit 1
fi

domainFile=${1}
hosts=$(cat ${domainFile} | sort -u)
dnsxResults=$(dnsx -j -silent -l ${domainFile} -mx -ns -asn)

tempDir=$(echo "/tmp/curl-results-"$(date +"%Y-%m-%d_%T"))
tempResult="${tempDir}/result.csv"
mkdir -p ${tempDir}

echo "Hostname ; Whois Domain ; Whois IP ; Mailserver ; NS Server ; ASN ; Effective URL ; Copyright ; Title ; Google Adsense ; Google Analytics ; Social Media ; Favicon" > "${tempResult}"

for domain in ${hosts}
do
    sleep 3

    # reset values
    hostResolveAble=""
    ipWhois=""
    mxHost=""
    nsHost=""
    asn=""
    effectiveUrl=""
    copyright=""
    httpTitle=""
    googleAdsense=""
    googleAnalytics=""
    socialMedia=""
    faviconStatus=""
    faviconHref=""
    mdHashFavicon=""
    domainWhois=""
 
    # get IPv4 (remove non printable characters)
    ipAddress=$(echo "${dnsxResults}" | jq -r --arg dom "${domain}" 'select(.host == $dom) | .a[]? // empty' | tr '\n' ' ' | sed 's/[^[:print:]]//g' )
 
    # get mailserver
    mxHost=$(echo "${dnsxResults}" | jq -r --arg dom "${domain}" 'select(.host == $dom) | .mx[]? // empty' | tr '\n' ' ' | sed 's/[^[:print:]]//g')

    # get nameserver
    nsHost=$(echo "${dnsxResults}" | jq -r --arg dom "${domain}" 'select(.host == $dom) | .ns[]? // empty' | tr '\n' ' ' | sed 's/[^[:print:]]//g')

    ipWhois=$(echo "${dnsxResults}" | jq -r --arg dom "${domain}" 'select(.host == $dom) | .asn["as-name"]? // empty' | tr '\n' ' ' | sed 's/[^[:print:]]//g')
 
    # get ASN (replace null by empty value)
    asn=$(echo "${dnsxResults}" | jq -r --arg dom "${domain}" 'select(.host == $dom) | .asn["as-number"]? // empty' | tr '\n' ' ' | sed 's/[^[:print:]]//g' | grep -v "jq: error ")
 
    # check if host can be resolved to ip address
    if [ -z ${ipAddress} ]
    then 
        # run curl
        tmpFile="${tempDir}/${domain}.html"
        curlOut=$(curl --connect-timeout 10 --max-time 10 -s -L -A "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36" -o "${tmpFile}" --write-out '%{http_code} %{url_effective}' "${domain}")
        httpStatus=$(echo ${curlOut} | cut -d " " -f 1)
        effectiveUrl=$(echo ${curlOut} | cut -d " " -f 2 | tr '\n' -d | sed 's/;//g')

        if [ -f ${tmpFile} ]
        then
            # grep copyright (remove non printable characters)
            copyright=$(cat ${tmpFile} | grep -Eio "[^<>\"']*©[^<>\"']*" | tail -n 1 | tr '\n' -d | sed 's/[;*-]/ /g' | sed 's/[^[:print:]]//g')
 
            # grep title
            httpTitle=$(cat ${tmpFile} | grep -Eio "<title>(.*)</title>" | cut -d ">" -f 2 | cut -d "<" -f1 | tr '\n' -d | sed 's/[;*-]/ /g' | sed 's/[^[:print:]]//g')
 
            # grep Google Adsense
            googleAdsense=$(cat ${tmpFile} | grep -Eio "pub-[0-9]{16}" | tr '\n' ',')
 
            # grep Google Analytics
            googleAnalytics=$(cat ${tmpFile} | grep -Eio "UA-[0-9]{9}-[0-9]" | tr '\n' ',')
 
            # grep social media profiles
            socialMedia=$(cat ${tmpFile} | grep -Eio "(linkedin\.com|youtube\.com|facebook\.com|github\.com|xing\.com)/[^?<>'\" ]*" | tr '\n' ',' | sed 's/;//g' | sed 's/[^[:print:]]//g')
 
            # get favicon hash
            tmpFileIco="${tempDir}/${domain}.ico"
            faviconStatus=$(curl -s -o "${tmpFileIco}" --write-out "%{http_code}" "${effectiveUrl}/favicon.ico" 2> /dev/null)

            if [[ "${faviconStatus}" -eq 200 ]]
            then
                mdHashFavicon=$(cat ${tmpFileIco} | md5sum | cut -d "-" -f 1)
            elif [ -f ${tmpFile} ]
            then
                faviconHref=$(cat ${tmpFile} | grep -Eio "[^<>\"']*favicon.ico[^<>\"']*")
 
                # if href contains https
                if [[ ${faviconHref} == *"https://"* ]]
                then
                    mdHashFavicon=$(curl --connect-timeout 10 --max-time 10 -s -L "${faviconHref}" | md5sum | awk -F ' ' '{print $1}' 2> /dev/null)
                else
                    mdHashFavicon=$(curl --connect-timeout 10 --max-time 10 -s -L "${effectiveUrl}/${faviconHref}" | md5sum | awk -F ' ' '{print $1}' 2> /dev/null)
                fi

                rm ${tmpFile}
            fi
        fi
    fi

    # get whois of domain
    domainWhois=$(whois ${domain} 2> /dev/null)
    organisation=$(echo ${domainWhois} | grep "^Registrant Organization: " | awk -F ": " '{print $2}' | sed 's/[^[:print:]]//g')

    # rerun whois command using another source, if result is empty
    if [ -z "${organisation}" ];
    then
        organisation=$(curl -s "https://www.whois.com/whois/${domain}" | grep -i "Registrant Organization: " | awk -F ": " '{print $2}' | sed 's/[^[:print:]]//g' 2> /dev/null)
    fi

    # print csv results
    echo "${domain} ; ${organisation} ; ${ipWhois} ; ${mxHost} ; ${nsHost} ; ${asn} ; ${effectiveUrl} ; ${copyright} ; ${httpTitle} ; ${googleAdsense} ; ${googleAnalytics} ; ${socialMedia} ; ${mdHashFavicon}" >> "${tempResult}"
done

# copy result csv to output directory
resultFileName=$(echo "${domainFile}" | sed 's/\//_/g' | sed 's/.txt//g')
cp ${tempResult} ${2}/${resultFileName}.csv

echo "Results:"
echo ""

# print coherent domains
awkResult=$(awk -F ";" '{ for (i=1; i<=NF; i++) count[$i]++ } END { for (word in count) if (count[word] > 1) print word}' "${tempResult}")
while IFS= read -r line
do
    # skip empty lines, whitespace and control charactes
    if ! echo "${line}" | grep -qP '^[[:space:][:cntrl:],]*$'
    then
        PURPLE='\033[0;35m'
        NC='\033[0m'
        printf "${PURPLE}${line}${NC}\n"
        grep "$line" "${tempResult}" | cut -d ";" -f 1
        echo ""
    fi
done <<< "${awkResult}"

rm -r ${tempDir}

