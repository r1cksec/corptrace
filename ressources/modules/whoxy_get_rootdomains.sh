#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} 'companyName'"
    echo "Run curl command and retrieve rootdomains from whoxy.com"
    exit 1
fi

# whoxy does not return any results if white space get encoded by +
company=$(echo "${1}" | cut -d " " -f 1)
curl -s "https://www.whoxy.com/keyword/${company}" | grep -o "<a href='../[^']*" | sed "s/<a href='..\/\([^']*\)/\1/" | grep -v "reverse-whois/"

