#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: crtsh_get_rootdomains 'companyName'"
    echo "Run curl command and retreive domains linked to the specified company name from crt.sh"
    exit
fi

urlEncodedInput=$(echo ${1} | sed -e 's/ /%20/g' -e 's/:/%3A/g' -e 's/\//%2F/g' -e 's/?/%3F/g' -e 's/=/%3D/g' -e 's/&/%26/g')

curl -s "https://crt.sh/?q=${urlEncodedInput}" \
| grep "<TD>" \
| grep -v "style=" \
| sed -n 's/.*<TD>\([^<]*\)<\/\?\([^>]*\)>.*/\1/p' \
| grep -iE '([[:alnum:]_.-]\.)+[A-Za-z]{2,6}$' \
| grep -v '@' \
| awk -F '.' '{print $(NF-1) "." $NF}' \
| tr '[:upper:]' '[:lower:]' \
| sort -u

