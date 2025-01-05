#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} 'companyName'"
    echo "Run curl command and retrieve rootdomains from whoxy.com"
    exit 1
fi

company=${1}
curl -s "https://www.whoxy.com/keyword/${company}" | grep -o "<a href='../[^']*" | sed "s/<a href='..\/\([^']*\)/\1/" | grep -v "reverse-whois/"

