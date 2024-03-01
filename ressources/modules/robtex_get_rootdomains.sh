#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} domain"
    echo "Run curl command and retrieve history of domains related to given ip address from robtex.com"
    exit 1
fi

domain=${1}
ip=$(dig +short ${domain})
resultPdns=$(curl -s "https://freeapi.robtex.com/pdns/reverse/${ip}")
resultStatus=$(echo "$resultPdns" | jq -r '.status')

# check if rate limit has been reached
if [ "${resultStatus}" = "ratelimited" ]
then
    echo "Rate limit reached"
else
    # write json output to file
    echo "${resultPdns}" | jq -r '.rrname' | sort -u
fi

