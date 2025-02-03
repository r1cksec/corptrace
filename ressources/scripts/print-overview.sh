#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} pathToCorptraceOutDir"
    exit 1
fi

resultDir=${1}

if [ ! -d ${resultDir} ]
then
    # nothing to print
    exit 
fi

echo ""

function collectResults()
{
    # path to module directory
    pathToDir=${1}

    # name of the result file
    nameScheme1=${2}
    
    # file extension
    nameScheme2=${3}
    
    # type of result (rootdomain, subdomain, email)
    resultType=${4}
    allFiles=""

    if [ -d "${pathToDir}" ]
    then
        allFiles=$(ls ${pathToDir})
    fi

    for f in ${allFiles}
    do
        domainName=""

        if [[ "${f}" == *"${nameScheme1}"* && "${f}" == *"${nameScheme2}"* ]]
        then
            if [ "${nameScheme2}" == "" ]
            then
                domainName=$(echo ${f} | awk -F "${2}" '{print $2}')
            else
                domainName=$(echo ${f} | awk -F "${2}" '{print $2}' | awk -F "${3}" '{print $1}')
            fi
 
            # remove lines that should not be included in results
            if [[ "${f}" == *"letItGo-"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | sed -n '/------/,/Stats:/{//!p}' | grep -v "These domains \|DOMAIN \|---" | awk -F ' ' '{print $1}' | grep -v 'onmicrosoft.com' >> "${resultDir}/${resultType}_${domainName}"

            elif [[ "${f}" == *"subfinder"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | grep -v "Current subfinder version" >> "${resultDir}/${resultType}_${domainName}"

            elif [[ "${f}" == *"dnstwist-"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | awk -F ' ' '{print $2}' >> "${resultDir}/${resultType}_${domainName}"

            elif [[ "${f}" == *"nmap_reverse_lookup-"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | awk -F ' ' '{print $1}' >> "${resultDir}/${resultType}_${domainName}"

            elif [[ "${f}" == *"massdns-"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | awk -F '. ' '{print $1}' >> "${resultDir}/${resultType}_${domainName}"

            else
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" >> "${resultDir}/${resultType}_${domainName}"
            fi

            # remove jq errors and no results found strings from results
            sort -u "${resultDir}/${resultType}_${domainName}" | grep -v "jq: error \|parse error: \|No results found for: \|Domain not found" > "${resultDir}/${resultType}_${domainName}-temp"
            mv "${resultDir}/${resultType}_${domainName}-temp" "${resultDir}/${resultType}_${domainName}"
        fi
    done
}

# create rootdomain files
collectResults "${resultDir}/letItGo" "letItGo-" "" "rootdomains" 
collectResults "${resultDir}/dns_get_top_level_domains" "dns_get_top_level_domains-" "" "rootdomains" 
collectResults "${resultDir}/dnstwist" "dnstwist-" "" "rootdomains" 
collectResults "${resultDir}/robtex_get_rootdomains" "robtex_get_rootdomains-" ".txt" "rootdomains" 
collectResults "${resultDir}/shodan_get_rootdomains_from_domain" "shodan_get_rootdomains_from_domain-" ".txt" "rootdomains" 
collectResults "${resultDir}/spyonweb_get_rootdomains" "spyonweb_get_rootdomains-" ".txt" "rootdomains" 
collectResults "${resultDir}/urlscan_get_rootdomains_from_domain" "urlscan_get_rootdomains_from_domain-" ".txt" "rootdomains" 
collectResults "${resultDir}/validin_get_rootdomains_from_domain" "validin_get_rootdomains_from_domain-" ".txt" "rootdomains" 
collectResults "${resultDir}/zoomeye_get_rootdomains_from_domain" "zoomeye_get_rootdomains_from_domain-" ".txt" "rootdomains" 

collectResults "${resultDir}/crtsh_get_rootdomains" "crtsh_get_rootdomains-" "" "rootdomains-company"
collectResults "${resultDir}/shodan_get_rootdomains_from_company" "shodan_get_rootdomains_from_company-" ".txt" "rootdomains-company"
collectResults "${resultDir}/urlscan_get_rootdomains_from_company" "urlscan_get_rootdomains_from_company-" ".txt" "rootdomains-company"
collectResults "${resultDir}/whoxy_get_rootdomains" "whoxy_get_rootdomains-" "" "rootdomains-company"

collectResults "${resultDir}/dnslytics_get_rootdomains" "dnslytics_get_rootdomains-" "" "rootdomains-ua"
collectResults "${resultDir}/hackertarget_get_rootdomains_from_gid" "hackertarget_get_rootdomains_from_gid-" "" "rootdomains-ua"

# create subdomain files
collectResults "${resultDir}/hackertarget_get_rootdomains_from_cidr" "hackertarget_get_rootdomains_from_cidr-" "" "domains-cidr"
collectResults "${resultDir}/nmap_get_tls_alternative_names" "nmap_get_tls_alternative_names-" "" "domains-cidr"
collectResults "${resultDir}/nmap_reverse_lookup" "nmap_reverse_lookup-" "" "domains-cidr"
collectResults "${resultDir}/networksdb_get_rootdomains_from_cidr" "networksdb_get_rootdomains_from_cidr-" ".txt" "domains-cidr"
collectResults "${resultDir}/validin_get_rootdomains_from_cidr" "validin_get_rootdomains_from_cidr-" ".txt" "domains-cidr"

collectResults "${resultDir}/massdns" "massdns-" "" "subdomains"
collectResults "${resultDir}/myssl_get_subdomains" "myssl_get_subdomains-" "" "subdomains"
collectResults "${resultDir}/subdomaincenter_get_subdomains" "subdomaincenter_get_subdomains-" "" "subdomains"
collectResults "${resultDir}/subfinder" "subfinder-" "" "subdomains"
collectResults "${resultDir}/urlscan_get_subdomains" "urlscan_get_subdomains-" ".txt" "subdomains"

# create email files
collectResults "${resultDir}/gpg_get_emails" "gpg_get_emails-" "" "emails"
collectResults "${resultDir}/hunter_get_emails" "hunter_get_emails-" ".txt" "emails"
collectResults "${resultDir}/phonebook_get_mails" "phonebook_get_mails-" ".txt" "emails"
collectResults "${resultDir}/skymem_get_mails" "skymem_get_mails-" "" "emails"
collectResults "${resultDir}/tomba_get_emails" "tomba_get_emails-" ".txt" "emails"

# create ip range files
collectResults "${resultDir}/networksdb_get_ipranges" "networksdb_get_ipranges-" ".txt" "iprange"
collectResults "${resultDir}/spk" "spk-" "" "iprange"

# print overview
shopt -s nullglob

# collect all rootdomains that contains subdomains
if [ "$(echo "${resultDir}"/subdomains_*)" != "" ]
then
    allSubdomains=$(ls "${resultDir}"/subdomains_* | awk -F 'subdomains_' '{print $2}' 2> /dev/null)
fi

# collect all rootdomains that contains email addresses
if [ "$(echo "${resultDir}"/emails_*)" != "" ]
then
    allEmails=$(ls "${resultDir}"/emails_* | awk -F 'emails_' '{print $2}' 2> /dev/null)
fi

allSpoofys=""

# collect all rootdomains where spf has been scanned
if [ -d "${resultDir}/spoofy" ]
then
    allSpoofys=$(ls "${resultDir}/spoofy" | awk -F 'spoofy-' '{print $2}')
fi

# merge all rootdomains for table overview
allResults="${allSubdomains} ${allEmails} ${allSpoofys}"
printDomains=$(echo "${allResults}" | tr ' ' '\n' | sort -u)
printf "%-40s %-30s %-30s %-30s\n" "Domain" "Subdomains" "Emails" "SPF"

for domain in ${printDomains}
do
    countSubdomains="?"
    countEmails="?"
    spoofable="?"

    if [ -f ${resultDir}/subdomains_${domain} ]
    then
        countSubdomains=$(cat "${resultDir}/subdomains_${domain}" | wc -l)
    fi 

    if [ -f ${resultDir}/emails_${domain} ]
    then
        countEmails=$(cat "${resultDir}/emails_${domain}" | wc -l)
    fi 

    if [ -f ${resultDir}/spoofy/spoofy-${domain} ]
    then
        spoofable="Configured"
        spfRecord=$(cat "${resultDir}/spoofy/spoofy-${domain}" | grep "No SPF record found.")

        if [ $? -eq 0 ]
        then
            spoofable="Pwn"
        fi
    fi

    printf "%-40s %-30s %-30s %-30s\n" "${domain}" "${countSubdomains}" "${countEmails}" "${spoofable}"
done

