#!/bin/bash

if [ ${#} -ne 3 ]
then
    echo "usage: ${0} domain teamsUser 'teamsPassword'"
    echo "MS Teams user must be email address from an organisation tenant without MFA"
    echo "Run curl command and retrieve email addresses from skymem.info and validate collaboration settings of MS Teams"
    exit 1
fi

domain=${1}
user=${2}
password=${3}
timeStamp=$(date +"%Y-%m-%d_%T")
tmpDir="/tmp/ms-teams-phishing-${timeStamp}"
mkdir -p "${tmpDir}"

curl -s "https://www.skymem.info/srch?q=${domain}" | grep 'href="/srch?q=' | grep -v "nbsp" | awk -F 'q=' '{print $2}' | cut -d '"' -f 1 > "${tmpDir}/mails.txt"
TeamsEnum -a password -u ${user} -p "${password}" -f "${tmpDir}/mails.txt"
rm -r "${tmpDir}"

