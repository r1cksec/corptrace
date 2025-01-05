#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} domain"
    exit 1
fi

domain=${1}
result=$(curl -s "https://myssl.com/api/v1/discover_sub_domain?domain=${domain}")
echo ${result} | jq -r '.data[] | .domain' | sort -u

