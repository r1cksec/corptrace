#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} 'companyName'"
    exit 1
fi

companyName=$(echo ${1} | sed 's/ /+/g')

searchUser=$(curl -s "https://api.github.com/search/users?q=${companyName}" | jq -r '.items[] | "\(.html_url) ; \(.type)"' | sort)
searchRepos=$(curl -s "https://api.github.com/search/repositories?q=${companyName}" | jq -r '.items[] | "\(.created_at) ; \(.html_url) ; \(.description) ; \(.homepage)"' | sort)
searchIssues=$(curl -s "https://api.github.com/search/issues?q=${companyName}" | jq -r '.items[] | "\(.created_at) ; \(.user .html_url) ; \(.html_url) ; \(.title))"' | sort)

echo "Url ; Type "
echo "${searchUser}"
echo ""
echo "Repository created_at ; Url ; Description ; Homepage"
echo "${searchRepos}"
echo ""
echo "Issue Timestamp ; User ; Url ; Title"
echo "${searchIssues}"

