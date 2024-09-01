#!/bin/bash

if [ ${#} -ne 2 ]
then
    echo "usage: ${0} repository outputDirectory"
    echo "Clone repository and run gitleaks, trufflehog, scanrepo, noseyparker"
    echo "repository: https://<url>"
    exit 1
fi

GR='\033[1;32m'
OR='\033[0;33m'
NC='\033[0m'

outputDir=${2}

timeStamp=$(date +"%Y-%m-%d_%T" | tr ':' '_')
globalTempDir="/tmp/get-github-secrets-${timeStamp}"

mkdir -p ${globalTempDir}

# clone repository
repo=${1}
repoName=$(echo ${repo} | awk -F "/" '{print $4"-"$5}')

# replace unwanted char
clearRepoName=${repoName//./-}
tmpRepoDir="${globalTempDir}/${clearRepoName}"

# clone repository
if [ ! -d ${tmpRepoDir} ]
then
    git clone --quiet ${repo} ${tmpRepoDir}
fi

# copy repositories
cp -r ${tmpRepoDir} ${tmpRepoDir}-gitleaks
cp -r ${tmpRepoDir} ${tmpRepoDir}-trufflehog
cp -r ${tmpRepoDir} ${tmpRepoDir}-scanrepo
cp -r ${tmpRepoDir} ${tmpRepoDir}-noseyparker

gitleaks detect --source ${tmpRepoDir}-gitleaks -v > ${globalTempDir}/gitleaks 2>&1 &

trufflehog git file://${tmpRepoDir}-trufflehog --no-update > ${globalTempDir}/truff 2>&1 &

timeStamp=$(date +"%Y-%m-%d_%T" | tr ':' '_')
tmpDataStore="${globalTempDir}/${timeStamp}-${repoDir}"
noseyparker scan --datastore ${tmpDataStore} ${tmpRepoDir}-noseyparker --progress never > /dev/null ; noseyparker report --datastore ${tmpDataStore} --progress never > ${globalTempDir}/noseyparker 2>&1 &

if [ -d ${tmpRepoDir}-scanrepo ]
then
    cd ${tmpRepoDir}-scanrepo
    git checkout --quiet origin
    git log -p | scanrepo > ${globalTempDir}/scanrepo 2>&1
    cd - > /dev/null &
else
    echo "Error!"
    exit 1
fi

wait

mkdir ${outputDir}/${clearRepoName}

echo ""
printf "${GR}###### gitleaks ######${NC}\n"
echo ""
cat ${globalTempDir}/gitleaks > ${outputDir}/${clearRepoName}/gitleaks
cat ${globalTempDir}/gitleaks 

echo ""
printf "${GR}###### trufflehog ######${NC}\n"
echo ""
cat ${globalTempDir}/truff > ${outputDir}/${clearRepoName}/trufflehog
cat ${globalTempDir}/truff

echo ""
printf "${GR}###### noseyparker ######${NC}\n"
echo ""
cat ${globalTempDir}/noseyparker > ${outputDir}/${clearRepoName}/noseyparker
cat ${globalTempDir}/noseyparker

echo ""
printf "${GR}###### scanrepo ######${NC}\n"
echo ""
cat ${globalTempDir}/scanrepo > ${outputDir}/${clearRepoName}/scanrepo
cat ${globalTempDir}/scanrepo

rm -rf "${globalTempDir}"

