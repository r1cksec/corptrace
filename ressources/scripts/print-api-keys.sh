#!/bin/bash

exeDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
apiKeys=$(cat "${exeDir}/../../build/config.json")

bevigil=$(echo "${apiKeys}" | jq -r '.bevigil_com')
if [[ ! -z ${bevigil} ]]
then
    echo "# bevigil.com"
    echo "50/month"
    echo ""
fi  

binaryedge=$(echo "${apiKeys}" | jq -r '.binaryedge_io')
if [[ ! -z ${binaryedge} ]]
then
    echo "# binaryedge.io"
    binaryedgeJson=$(curl -s "https://api.binaryedge.io/v2/user/subscription" -H "X-Key: ${binaryedge}")
    binaryedgeRequestsPlan=$(echo ${binaryedgeJson} | jq -r '.requests_plan')
    binaryedgeRequestsLeft=$(echo ${binaryedgeJson} | jq -r '.requests_left')
    binaryedgeRequestsLeft2=$(echo "${binaryedgeRequestsPlan} - ${binaryedgeRequestsLeft}" | bc)
    echo "${binaryedgeRequestsLeft2}/${binaryedgeRequestsPlan} -> ${binaryedgeRequestsLeft}"
    echo ""
fi

bufferover=$(echo "${apiKeys}" | jq -r '.bufferover_run')
if [[ ! -z ${bufferover} ]]
then
    echo "# bufferover.run"
    echo "100/month"
    echo ""
fi

censys=$(echo "${apiKeys}" | jq -r '.censys_io')
if [[ ! -z ${censys} ]]
then
    echo "# censys.io"
    curl -s "https://search.censys.io/api/v1/account" -H "accept: application/json" -H "Authorization: Basic ${censys}" | jq -r '.quota | "\(.used)/\(.allowance) -> \(.resets_at)"'
    echo ""
fi

fullhunt=$(echo "${apiKeys}" | jq -r '.fullhunt_io')
if [[ ! -z ${fullhunt} ]]
then
    echo "# fullhunt.io"
    echo "100/month"
    echo ""
fi

github=$(echo "${apiKeys}" | jq -r '.github_com')
if [[ ! -z ${github} ]]
then
    echo "# github.com"
    curl -s "https://api.github.com/rate_limit" -H "Authorization: Bearer ${github}" | jq -r '.rate | "\(.used)/\(.limit) -> \(.reset | strftime("%Y-%m-%d %H:%M:%S"))"'
    echo ""
fi

#grayhatwarfare=$(echo "${apiKeys}" | jq -r '.grayhatwarfare_com')
#if [[ ! -z ${grayhatwarfare} ]]
#then
#    echo "# grayhatwarfare.com"
#    echo "_/_"
#    echo ""
#fi

hunter=$(echo "${apiKeys}" | jq -r '.hunter_io')
if [[ ! -z ${hunter} ]]
then
    echo "# hunter.io"
    curl -s "https://api.hunter.io/v2/account?api_key=${hunter}" | jq -r '.data .requests .searches as $s | "\($s .used)/\($s .available) -> \(.data .reset_date)"'
    echo ""
fi

intelx=$(echo "${apiKeys}" | jq -r '.intelx_io')
if [[ ! -z ${intelx} ]]
then
    echo "# intelx.io"
    intelxJson=$(curl -s -H "x-key: ${intelx}" "https://2.intelx.io/authenticate/info")
    intelxCreditMax=$(echo ${intelxJson} | jq -r '.paths ."/phonebook/search" | .CreditMax')
    intelxCredit=$(echo ${intelxJson} | jq -r '.paths ."/phonebook/search" | .Credit')
    intelxCredit2=$(echo "${intelxCreditMax} - ${intelxCredit}" | bc)
    echo "${intelxCredit2}/${intelxCreditMax} -> 10/day"
    echo ""
fi

if [[ ! -z $(echo "${apiKeys}" | jq -r '.leakix_net') ]]
then
    echo "# leakix.net"
    echo "3000/month"
    echo ""
fi

netlas=$(echo "${apiKeys}" | jq -r '.netlas_io')
if [[ ! -z ${netlas} ]]
then
    echo "# netlas.io"
    netlasJson=$(curl -s -H "X-API-Key: ${netlas}" "https://app.netlas.io/api/users/current/")
    netlasCoins=$(echo ${netlasJson} | jq -r '.plan .coins')
    netlasCoins2=$(echo "(2500 - ${netlasCoins}) / 20" | bc)
    netlasUpdate=$(echo ${netlasJson} | jq -r '.api_key .next_time_coins_will_be_updated')
    echo "${netlasCoins2}/125 -> 50/day 125/month "
    echo ""
fi

networksdb=$(echo "${apiKeys}" | jq -r '.networksdb_io')
if [[ ! -z ${networksdb} ]]
then
    echo "# networksdb.io"
    curl -sH "X-Api-Key: ${networksdb}" "https://networksdb.io/api/key" | jq -r '"\(.req_count)/\(.req_limit) -> \(.resets_at)"'
    echo ""
fi

#projectdiscovery=$(echo "${apiKeys}" | jq -r '.projectdiscovery_io')
#if [[ ! -z ${projectdiscovery} ]]
#then
#    echo "# projectdiscovery.io"
#    echo "_/_"
#    echo ""
#fi

#robtex=$(echo "${apiKeys}" | jq -r '.robtex_com')
#if [[ ! -z "${robtex}" ]]
#then
#    echo "# robtex.com"
#    echo "_/_"
#    echo ""
#fi

securitytrails=$(echo "${apiKeys}" | jq -r '.securitytrails_com')
if [[ ! -z ${securitytrails} ]]
then
    echo "# securitytrails.com"
    curl -s --request GET --url "https://api.securitytrails.com/v1/account/usage" -H "APIKEY: ${securitytrails}" | jq -r '"\(.current_monthly_usage)/\(.allowed_monthly_usage) -> \(.allowed_monthly_usage)/month"'
    echo ""
fi

shodan=$(echo "${apiKeys}" | jq -r '.shodan_io')
if [[ ! -z ${shodan} ]]
then
    echo "# shodan.io"
    shodanJson=$(curl -s "https://api.shodan.io/api-info?key=${shodan}")
    shodanCredits=$(echo ${shodanJson} | jq -r '.usage_limits .query_credits')
    shodanCreditsLeft=$(echo ${shodanJson} | jq -r '.query_credits')
    shodanCredits2=$(echo "${shodanCredits} - ${shodanCreditsLeft}" | bc)
    echo "${shodanCredits2}/${shodanCredits} -> ${shodanCredits}/month "
    echo ""
fi

if [[ ! -z $(echo "${apiKeys}" | jq -r '.spyonweb_com') ]]
then
    echo "# spyonweb.com"
    echo "200/month"
    echo ""
fi

#sslmate=$(echo "${apiKeys}" | jq -r '.sslmate_com')
#if [[ ! -z ${sslmate} ]]
#then
#    echo "# sslmate.com"
#    echo "_/_"
#    echo ""
#fi

tombats=$(echo "${apiKeys}" | jq -r '.["tomba_io_ts"]')
tombata=$(echo "${apiKeys}" | jq -r '.["tomba_io_ta"]')
if [[ ! -z ${tombats} ]]
then
    echo "# tomba.io"
    tombaUsage=$(curl -s --request GET --url "https://api.tomba.io/v1/usage" -H "X-Tomba-Key: ${tombata}" -H "X-Tomba-Secret: ${tombats}" | jq -r '.total .search')
    echo "${tombaUsage}/50 -> 50/month"
	echo ""
fi

urlscan=$(echo "${apiKeys}" | jq -r '.urlscan_io')
if [[ ! -z ${urlscan} ]]
then
    echo "# urlscan.io"
    urlscanJson=$(curl -s "https://urlscan.io/user/quotas" -H "API-Key: ${urlscan}")
    urlscanLimit=$(echo ${urlscanJson} | jq -r '.limits .search .day .limit')
    urlscanUsage=$(echo ${urlscanJson} | jq -r '.limits .search .day .used')
    echo "${urlscanUsage}/${urlscanLimit} -> ${urlscanLimit}/day"
    echo ""
fi

validin=$(echo "${apiKeys}" | jq -r '.validin_com')
if [[ ! -z ${validin} ]]
then
    echo "# validin.com"
    echo "50/day 250/month"
    echo ""
fi

virustotal=$(echo "${apiKeys}" | jq -r '.virustotal_com')
if [[ ! -z ${virustotal} ]]
then
    echo "# virustotal.com"
    echo "500/day"
    echo ""
fi

zoomeye=$(echo "${apiKeys}" | jq -r '.zoomeye_org')
if [[ ! -z ${zoomeye} ]]
then
    echo "# zoomeye.hk"
    zoomeyeLeft=$(curl -s -X GET "https://api.zoomeye.hk/resources-info" -H "API-KEY:${zoomeye}" | jq -r '.resources .search')
    zoomeyeUsage=$(echo "(10000 - ${zoomeyeLeft}) / 20" | bc)
    echo "${zoomeyeUsage}/500 -> 500/month"
    echo ""
fi

