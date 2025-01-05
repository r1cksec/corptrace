#!/bin/bash

if [ ${#} -ne 1 ]
then
    echo "usage: ${0} repository"
    echo "Run multiple grep and git log commands for github repository"
    exit 1
fi

Y='\033[0;33m'
N='\033[0m'

# define paths to temporary files and dir
repo=${1}
repoDir=$(echo ${repo} | awk -F "/" '{print $4"-"$5}')

timeStamp=$(date +"%Y-%m-%d_%T")
tmpDir="/tmp/grep-inside-${repoDir}-${timeStamp}"
commitFile="${tmpDir}/commits"
tempFinds="${tmpDir}/finds"
tempGreps="${tmpDir}/greps"

# check if repository exists
repoExists=$(curl -s -o /dev/null -w "%{http_code}" "${repo}")

if [ "${repoExists}" -ne 200 ];
then
    echo "Error repository ${repo} does not exist or is not public."
    exit 1
fi

# clone repository
mkdir -p "${tmpDir}/git-repo"
git clone --quiet ${repo} "${tmpDir}/git-repo"

cd "${tmpDir}/git-repo"

# get each commit
git checkout --quiet origin
authorEmails=$(git log --quiet | grep "Author: " | awk -F " <" '{print $2}' | cut -d ">" -f 1 | grep -v "users.noreply" | sort -u)
git log --quiet | grep '^commit ' | cut -d " " -f 2 > ${commitFile}
printf "${Y}########## Commit messages ########## ${N}\n"

# search for this keywords and file extensions
declare -a allKeyWords=("ssh .*@.*" "ftp .*@.*" "-AsPlainText" "passwor[t,d]=" "access[-_]token" "api[-_]key" "private[-_]key")
declare -a allFileExtensions=("*.conf" "*.cnf" "*.cfg" "*.config" "*.kdb" "*.kdbx" "*.key" "*.p12" "*.pem" "*.rdp" "*.pfx" "*.remmina" "*.vdi" ".ini")

# iterate through each commit and grep and search for values inside arrays
while read -r commitId || [[ -n "${commitId}" ]]
do
    commitDate=$(git log --format="%ad" -n 1 ${commitId})
    commitMsg=$(git log --format="%B" -n 1 ${commitId} | tr -d '\n')
    echo "${commitDate} ${commitMsg}"
    git checkout --quiet ${commitId}
    
    for k in "${allKeyWords[@]}"
    do
        grep --color=always -IEiRo ".{0,20}${k}.{0,20}" * >> ${tempGreps}
    done

    for f in "${allFileExtensions[@]}"
    do
        find . -iname "${f}" | cut -c2- | awk -v g="${1}" -v c="${commitId}" '{print g"/blob/"c$1}' >> ${tempFinds}
    done
    
done < ${commitFile}

echo ""
printf "${Y}########## Grep results ########## ${N}\n"
sort -u ${tempGreps}
echo ""
printf "${Y}########## Find results ########## ${N}\n"
sort -u ${tempFinds}

echo ""
printf "${Y}########## Author emails ########## ${N}\n"
echo "${authorEmails}"
echo ""
echo ""

# remove temporary files
cd /tmp
rm -rf ${tmpDir}

