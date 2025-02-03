#!/bin/bash

if [ ${#} -ne 2 ]
then
    echo "usage: pathToCorpTraceOutDir [light/dark]"
    exit 1
fi

# construct json object from csv line 
function getCoherentDomains()
{
    rootdom=${1}
    number=${2}
    string=${3}
    key=${4}
    endOfObj=${5}

    attribute=$(echo "${string}" | cut -d ";" -f "${number}")

    # skip empty attributes
    if ! [[ "${attribute}" =~ ^[[:space:]]*$ ]]
    then
        echo -n "\"${key}\":\"${attribute}\","

        echo -n "\"${key} relation\":["
        # sed used to remove last , from json
        grep "${attribute}" ${tempCsv} | grep -v "${rootdom} ;" | awk '{print "\""$1"\""}' | tr '\n' ',' | sed 's/.$//'

        if [[ -z "${endOfObj}" ]]
        then
            echo -n "],"
        else
            echo -n "]"
        fi
    else
        echo -n "\"${key}\":\"?\","

        if [[ -z "${endOfObj}" ]]
        then
            echo -n "\"${key} relation\":[],"
        else
            echo -n "\"${key} relation\":[]"
        fi
    fi
}

tempCsv="/tmp/$(date +"%Y-%m-%d_%T")-visualize-all-results.csv"
resultFile="${1}/dnsx_get_coherent_domains/graph.html"
theme=${2}

exeDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pathToHtmlTemplate1="${exeDir}/../templates/graph-template1-${theme}.html"
pathToHtmlTemplate2="${exeDir}/../templates/graph-template2-${theme}.html"

if [ ! -d ${1}/dnsx_get_coherent_domains ]
then
    echo "${1}/dnsx_get_coherent_domains does not exists!"
    echo "Run: python3 corptrace.py -o ${1} -f ${1}/some-domains.txt -im dnsx -e"
    exit 1
fi

cat ${1}/dnsx_get_coherent_domains/*/* | grep -v "Hostname ; Whois Domain " | sort -u > ${tempCsv}

if [ $? -ne 0 ]
then
    echo "No file found: ${1}/dnsx_get_coherent_domains/*/*"
    echo "Check source code of ${exeDir} for more info.."
    exit 1
fi

amountOfLines=$(cat ${tempCsv} | wc -l)
counter=1

# write first part of html file
cat ${pathToHtmlTemplate1} > ${resultFile}

echo -n "const data = [" >> ${resultFile}

# -r prevents backslashes from being interpreted, -n reads last line
while read -r line || [[ -n "${line}" ]]
do
    # skip empty lines
    if ! [ -z "${line}" ]
    then

        rootdomain=$(echo ${line} | cut -d ";" -f 1) >> ${resultFile}

        # get amount of subdomains
        if [ ! -f ${1}/subdomains_${rootdomain} ]
        then
            amountOfSubdomains="?"
        else
            amountOfSubdomains=$(cat ${1}/subdomains_${rootdomain} | wc -l)
        fi
        
        # get amount of emails
        if [ ! -f ${1}/emails_${rootdomain} ]
        then
            amountOfEmails="?"
        else
            amountOfEmails=$(cat ${1}/emails_${rootdomain} | wc -l)
        fi

        # get SPF status
        if [ -f ${1}/spoofy/spoofy-${rootdomain} ]
        then
            if grep -q "No SPF record found" ${1}/spoofy/spoofy-${rootdomain}
            then
                spfStatus="Pwn"
            else
                spfStatus="Configured"
            fi
        else
            spfStatus="?"
        fi

        echo -n "{" >> ${resultFile}
        echo -n "\"Rootdomain\":\"${rootdomain}\"," >> ${resultFile}
        echo -n "\"Subdomains\":\"${amountOfSubdomains}\"," >> ${resultFile}
        echo -n "\"Emails\":\"${amountOfEmails}\"," >> ${resultFile}
        echo -n "\"SPF\":\"${spfStatus}\"," >> ${resultFile}

        # remove "
        lineNoQuote=$(echo "${line}" | sed 's/"/_/g')

    	# getCoherentDomains rootdomain columnNumber csvLine jsonKey flag
        getCoherentDomains ${rootdomain} 2 "${lineNoQuote}" "Whois Domain" >> ${resultFile}
        getCoherentDomains ${rootdomain} 3 "${lineNoQuote}" "Whois Ip" >> ${resultFile}
        getCoherentDomains ${rootdomain} 4 "${lineNoQuote}" "Mailserver" >> ${resultFile}
        getCoherentDomains ${rootdomain} 5 "${lineNoQuote}" "Nameserver" >> ${resultFile}
        getCoherentDomains ${rootdomain} 6 "${lineNoQuote}" "ASN" >> ${resultFile}
        getCoherentDomains ${rootdomain} 7 "${lineNoQuote}" "Effective Url" >> ${resultFile}
        getCoherentDomains ${rootdomain} 8 "${lineNoQuote}" "Copyright" >> ${resultFile}
        getCoherentDomains ${rootdomain} 9 "${lineNoQuote}" "Title" >> ${resultFile}
        getCoherentDomains ${rootdomain} 10 "${lineNoQuote}" "Google Adsense" >> ${resultFile}
        getCoherentDomains ${rootdomain} 11 "${lineNoQuote}" "Google Analytics" >> ${resultFile}
        getCoherentDomains ${rootdomain} 12 "${lineNoQuote}" "Social Media" >> ${resultFile}
        getCoherentDomains ${rootdomain} 13 "${lineNoQuote}" "Favicon" "end" >> ${resultFile}

        if [ "${amountOfLines}" == "${counter}" ]
        then
            echo -n "}" >> ${resultFile}
        else
            echo -n "}," >> ${resultFile}
        fi

        let counter=${counter}+1

    fi
done < ${tempCsv}

echo "];" >> ${resultFile}

# write second part of html file
cat ${pathToHtmlTemplate2} >> ${resultFile}

# remove tempory file
rm -r ${tempCsv}

