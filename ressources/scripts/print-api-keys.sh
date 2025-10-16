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

bufferover=$(echo "${apiKeys}" | jq -r '.bufferover_run')
if [[ ! -z ${bufferover} ]]
then
    echo "# bufferover.run"
    echo "100/month"
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

hunter=$(echo "${apiKeys}" | jq -r '.hunter_io')
if [[ ! -z ${hunter} ]]
then
    echo "# hunter.io"
    curl -s "https://api.hunter.io/v2/account?api_key=${hunter}" | jq -r '.data .requests .searches as $s | "\($s .used)/\($s .available) -> \(.data .reset_date)"'
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

tombats=$(echo "${apiKeys}" | jq -r '.["tomba_io_ts"]')
tombata=$(echo "${apiKeys}" | jq -r '.["tomba_io_ta"]')
if [[ ! -z ${tombats} ]]
then
    echo "# tomba.io"
    tombaUsage=$(curl -s --request GET --url "https://api.tomba.io/v1/usage" -H "X-Tomba-Key: ${tombata}" -H "X-Tomba-Secret: ${tombats}" | jq -r '.total .search')
    echo "${tombaUsage}/25 -> 25/month"
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

zoomeye=$(echo "${apiKeys}" | jq -r '.zoomeye_ai')
if [[ ! -z ${zoomeye} ]]
then
    echo "# zoomeye.ai"
    result=$(curl -s -X POST "https://api.zoomeye.ai/v2/userinfo" -H "API-KEY: ${zoomeye}")
    zoomeyepoint=$(echo "${result}" | jq -r '.data .subscription .zoomeye_points')
    zoomeyepointsgeneric=$(echo "${result}" | jq -r '.data .subscription .points')
    echo "${zoomeyepoint}/2000 -> 2000/year"
    echo "${zoomeyepointsgeneric}/3000 -> 3000/month"
    echo ""
fi

