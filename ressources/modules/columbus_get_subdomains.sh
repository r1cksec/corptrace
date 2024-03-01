#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} domain"
    exit 1
fi

domain=${1}
result=$(curl -s "https://columbus.elmasy.com/api/lookup/${domain}?days=365")
errorMsg=$(echo ${result} | jq -r '.error' 2> /dev/null)

if [ "not found" == "${errorMsg}" ]
then
    echo "Domain not found"
else
    echo ${result} | jq -r ".[] | select(.) | \"\\(.)\" + \".${domain}\"" | grep -ve "^\.${domain}"
fi

