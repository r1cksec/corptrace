#!/bin/bash

if [ ${#} -eq 1 ]
then
    read -p "Enter github.com ApiKey: " apiKey
elif [ ${#} -eq 2 ]
then
    apiKey=${2}
else
    echo "usage: ${0} account [apiKey]"
    echo "account: name of user or organisation on github.com"
    echo "Run curl commands and retrieve member information from github organisation"
    exit 1
fi

function getOrgMember()
{
    echo "Organisation: ${1}"
    # get all usernames of organisation
    orgMember=$(curl -s "https://api.github.com/orgs/${1}/members" -H "Authorization: Bearer ${apiKey}" | jq -r ".[] .login")
    echo "Url ; Created_at ; Company ; Bio ; Blog ; Location ; Email ; Twitter ; Follower ; Following ; Authormail"

    for user in ${orgMember}
    do
        # get information about each user
        userInfo=$(curl -s "https://api.github.com/users/${user}" -H "Authorization: Bearer ${apiKey}")
        csvUserInfo=$(echo "${userInfo}" | jq -r '"\(.html_url) ; \(.created_at) ; \(.company) ; \(.bio | if . != null then gsub(";"; "_") else "" end) ; \(.blog) ; \(.location) ; \(.email) ; \(.twitter_username) ; \(.followers) ; \(.following)"')
        # remove line breaks
        csvUserInfoNoLb=$(echo ${csvUserInfo} | tr -d '\r\n' | tr -d '\n')

        # get user commit author email address
        commitsAsc=$(curl -s "https://api.github.com/search/commits?q=author:${user}&sort=author-date&order=asc" -H "Authorization: Bearer ${apiKey}")
        commitsDesc=$(curl -s "https://api.github.com/search/commits?q=author:${user}&sort=author-date&order=desc" -H "Authorization: Bearer ${apiKey}")
        possAscMails=$(echo ${commitsAsc} | jq -r '.items[] | select(.commit.author.email != null or .commit.committer.email != null) | .commit.author.email, .commit.committer.email')
        possDescMails=$(echo ${commitsDesc} | jq -r '.items[] | select(.commit.author.email != null or .commit.committer.email != null) | .commit.author.email, .commit.committer.email')
        email=$(echo -e "${possAscMails}\n${possDescMails}" | grep -v "@users.noreply.github.com\|noreply@github.com" | sort -u | tr '\r\n' '/' | tr '\n' ' / ')

        # print result
        echo "${csvUserInfoNoLb} ; ${email}"
    done

    echo ""
}

account=${1}
accountInfo=$(curl -s "https://api.github.com/users/${account}" -H "Authorization: Bearer ${apiKey}")
accountType=$(echo "${accountInfo}" | jq -r 'if has("type") then .type else .message end')

# check if account is an organisation
if [ "${accountType}" == "Organization" ]
then
    getOrgMember "${account}"
elif [ "${accountType}" == "User" ]
then
    allOrgs=$(curl -s "https://api.github.com/users/${account}/orgs" | jq -r ".[] .login")
    
    for org in ${allOrgs}
    do
        getOrgMember "${org}"
    done
else
    echo ${accountType}
fi

