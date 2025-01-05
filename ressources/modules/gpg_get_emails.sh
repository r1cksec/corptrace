#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} domain"
    exit 1
fi

domain=${1}

ubuntuResult=$(curl -s "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=vindex&search=${domain}" | grep -oiE '([[:alnum:]_.-]+@[[:alnum:]_.-]+?\.[[:alpha:].]{2,6})' | tr '[:upper:]' '[:lower:]')
earthResult=$(curl -s "http://the.earth.li:11371/pks/lookup?fingerprint=on&op=vindex&search=${domain}" | grep -oiE '([[:alnum:]_.-]+@[[:alnum:]_.-]+?\.[[:alpha:].]{2,6})' | tr '[:upper:]' '[:lower:]')

echo -e "${ubuntuResult}\n${earthResult}" | grep "${domain}" | sort -u

