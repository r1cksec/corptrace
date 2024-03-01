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
    pathToDir=${1}
    nameScheme1=${2}
    nameScheme2=${3}
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
 
            if [[ "${f}" == *"letItGo-"* ]]
            then
                cat "$pathToDir/${nameScheme1}${domainName}${nameScheme2}" | sed -n '/------/,/Stats:/{//!p}' | grep -v "These domains \|DOMAIN \|---" | awk -F ' ' '{print $1}' | grep -v 'onmicrosoft.com' >> "${resultDir}/${resultType}_${domainName}"
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

            sort -u "${resultDir}/${resultType}_${domainName}" > "${resultDir}/${resultType}_${domainName}-temp"
            mv "${resultDir}/${resultType}_${domainName}-temp" "${resultDir}/${resultType}_${domainName}"
        fi
    done
}

# create rootdomain files
collectResults "${resultDir}/letItGo" "letItGo-" "" "rootdomains" 
collectResults "${resultDir}/dns_get_top_level_domains" "dns_get_top_level_domains-" "" "rootdomains" 
collectResults "${resultDir}/dnstwist" "dnstwist-" "" "rootdomains" 
collectResults "${resultDir}/onyphe_get_rootdomains" "onyphe_get_rootdomains-" ".txt" "rootdomains" 
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
collectResults "${resultDir}/validin_get_rootdomains_from_cidr" "validin_get_rootdomains_from_cidr-" ".txt" "domains-cidr"

collectResults "${resultDir}/columbus_get_subdomains" "columbus_get_subdomains-" "" "subdomains"
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

if [ "$(echo "${resultDir}"/subdomains_*)" != "" ]
then
    allSubdomains=$(ls "${resultDir}"/subdomains_* | awk -F 'subdomains_' '{print $2}' 2> /dev/null)
fi

if [ "$(echo "${resultDir}"/emails_*)" != "" ]
then
    allEmails=$(ls "${resultDir}"/emails_* | awk -F 'emails_' '{print $2}' 2> /dev/null)
fi

allSpoofys=""
allTeams=""

if [ -d "${resultDir}/spoofy" ]
then
    allSpoofys=$(ls "${resultDir}/spoofy" | awk -F 'spoofy-' '{print $2}')
fi

if [ -d "${resultDir}/msteams_phishing" ]
then
    allTeams=$(ls "${resultDir}/msteams_phishing" | awk -F 'msteams_phishing-' '{print $2}')
fi

allResults="${allSubdomains} ${allEmails} ${allSpoofys} ${allTeams}"
printDomains=$(echo "${allResults}" | tr ' ' '\n' | sort -u)
printf "%-20s %-20s %-20s %-20s %-20s\n" "Domain" "Subdomains" "Emails" "SPF" "MsTeams"

for domain in ${printDomains}
do
    countSubdomains="?"
    countEmails="?"
    spoofable="?"
    collab="?"

    if [ -f ${resultDir}/rootdomains_${domain} ]
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

    if [ -f ${resultDir}/msteams_phishing/msteams_phishing-${domain} ]
    then
        collab="Unreachable"
        teamsCollab=$(cat "${resultDir}/msteams_phishing/msteams_phishing-${domain}" | grep -v "\[+\] Successfully \|\[+\] Found " | grep "\[+\]")

        if [ $? -eq 0 ]
        then
            collab="Pwn"
        fi
    fi

    printf "%-20s %-20s %-20s %-20s %-20s\n" "${domain}" "${countSubdomains}" "${countEmails}" "${spoofable}" "${collab}"
done

