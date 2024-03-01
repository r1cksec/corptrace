#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} filedomains"
    echo "filedomains: File containing domains, one per line"
    exit 1
fi

domainFile=${1}
hosts=$(cat ${domainFile} | sort -u)
mailServer=$(dnsx -silent -l ${domainFile} -mx -resp)
nsServer=$(dnsx -silent -l ${domainFile} -ns -resp)
asNumbers=$(dnsx -silent -l ${domainFile} -asn)

tempDir=$(echo "/tmp/curl-results-"$(date +"%Y-%m-%d_%T"))
tempResult="${tempDir}/result.csv"
mkdir -p ${tempDir}

echo "Hostname ; Whois Domain ; Whois IP ; Mailserver ; NS Server ; ASN ; Effective URL ; Copyright ; Title ; Google Adsense ; Google Analytics ; Social Media ; Favicon"

for domain in ${hosts}
do
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
 
    # get whois of IP
    hostResolveAble=$(echo "${asNumbers}" | grep "${domain}")
    ipWhois=$(echo "${asNumbers}" | grep "${domain}" | cut -d "[" -f 2 | cut -d "]" -f 1 | cut -d "," -f 2)
 
    # get mailserver
    mxHost=$(echo -e "${mailServer}" | grep "${domain}" | cut -d "[" -f 2 | cut -d "]" -f 1 | tr '\n' ',')

    # get nameserver
    nsHost=$(echo -e "${nsServer}" | grep "${domain}" | cut -d "[" -f 2 | cut -d "]" -f 1 | tr '\n' ',')
 
    # get ASN
    asn=$(echo "${asNumbers}" | grep "${domain}" | cut -d "[" -f 2 | cut -d "]" -f 1 | cut -d "," -f 1)
 
    # check if host can be resolved to ip address
    if grep -q "${domain}" <<< "${hostResolveAble}" 
    then 
        # run curl
        tmpFile="${tempDir}/${domain}.html"
        curlOut=$(curl --connect-timeout 10 --max-time 10 -s -L -o "${tmpFile}" --write-out '%{http_code} %{url_effective}' "${domain}")
        httpStatus=$(echo ${curlOut} | cut -d " " -f 1)
        effectiveUrl=$(echo ${curlOut} | cut -d " " -f 2)

        if [ -f ${tmpFile} ]
        then
            # grep copyright
            copyright=$(cat ${tmpFile} | grep -Eio "[^<>\"']*©[^<>\"']*" | tail -n 1 | tr '\n' -d | sed 's/;//g')
 
            # grep title
            httpTitle=$(cat ${tmpFile} | grep -Eio "<title>(.*)</title>" | cut -d ">" -f 2 | cut -d "<" -f1 | tr '\n' -d | sed 's/;//g')
 
            # grep Google Adsense
            googleAdsense=$(cat ${tmpFile} | grep -Eio "pub-[0-9]{16}" | tr '\n' ',')
 
            # grep Google Analytics
            googleAnalytics=$(cat ${tmpFile} | grep -Eio "UA-[0-9]{9}-[0-9]" | tr '\n' ',')
 
            # grep social media profiles
            socialMedia=$(cat ${tmpFile} | grep -Eio "(linkedin\.com|youtube\.com|facebook\.com|github\.com|xing\.com)/[^?<>'\" ]*" | tr '\n' ',' | sed 's/;//g')
 
            # get favicon hash
            tmpFileIco="${tempDir}/${domain}.ico"
            faviconStatus=$(curl -s -o "${tmpFileIco}" --write-out "%{http_code}" "${effectiveUrl}/favicon.ico")

            if [[ "${faviconStatus}" -eq 200 ]]
            then
                mdHashFavicon=$(cat ${tmpFileIco} | md5sum | cut -d "-" -f 1)
            elif [ -f ${tmpFile} ]
            then
                faviconHref=$(cat ${tmpFile} | grep -Eio "[^<>\"']*favicon.ico[^<>\"']*")
 
                # if href contains https
                if [[ ${faviconHref} == *"https://"* ]]
                then
                    mdHashFavicon=$(curl --connect-timeout 10 --max-time 10 -s -L "${faviconHref}" | md5sum | awk -F ' ' '{print $1}')
                else
                    mdHashFavicon=$(curl --connect-timeout 10 --max-time 10 -s -L "${effectiveUrl}/${faviconHref}" | md5sum | awk -F ' ' '{print $1}')
                fi

                rm ${tmpFile}
            fi
        fi
    fi

    # get whois of domain
    domainWhois=$(whois ${domain} | grep "^Registrant Organization: " | awk -F ": " '{print $2}' 2> /dev/null)

    # rerun whois command using another source, if rate limit reached
    if [ ${$?} -ne 0 ]
    then
        domainWhois=$(curl -s "https://www.whois.com/whois/${domain}" | grep -i "Registrant Organization: " | awk -F ": " '{print $2}' 2> /dev/null)
    fi

    # print csv results
    echo "${domain} ; ${domainWhois} ; ${ipWhois} ; ${mxHost} ; ${nsHost} ; ${asn} ; ${effectiveUrl} ; ${copyright} ; ${httpTitle} ; ${googleAdsense} ; ${googleAnalytics} ; ${socialMedia} ; ${mdHashFavicon}"
    echo "${domain} ; ${domainWhois} ; ${ipWhois} ; ${mxHost} ; ${nsHost} ; ${asn} ; ${effectiveUrl} ; ${copyright} ; ${httpTitle} ; ${googleAdsense} ; ${googleAnalytics} ; ${socialMedia} ; ${mdHashFavicon}" >> "${tempResult}"
done

echo ""
echo ""

# print coherent domains
awkResult=$(awk -F ";" '{ for (i=1; i<=NF; i++) count[$i]++ } END { for (word in count) if (count[word] > 1) print word}' "${tempResult}")

while IFS= read -r line
do
    # skip empty lines
    if [ "${line}" != "  " ] && [ "${line}" != " " ]
    then
        echo "##### ${line}"
        grep "$line" "${tempResult}" | cut -d ";" -f 1
        echo ""
    fi
done <<< "${awkResult}"

rm -r ${tempDir}

