#!/bin/bash

# stop on error
set -e

# stop on undefined
set -u

if [ "$EUID" -ne 0 ]
then
    echo "Please run script as root"
    exit
fi

echo ""
echo "### AMD Setup Script"
echo ""
sleep 3

# Write path to scripts into module.json file
pathToScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
sed -i "s|REPLACEME|${pathToScriptDir}|g" "${pathToScriptDir}/modules.json"

echo ""
echo "### APT Install"
apt install dnsrecon git wget python3 python3-pip whois curl nmap

echo ""
echo "### Wget precompiled binaries from: https://github.com/r1cksec/misc/tree/main/binaries"
echo ""
wget https://github.com/r1cksec/misc/raw/main/binaries/massdns -O /usr/local/bin/massdns
chmod +x /usr/local/bin/massdns
wget https://github.com/r1cksec/misc/raw/main/binaries/spk -O /usr/local/bin/spk
chmod +x /usr/local/bin/spk
wget https://github.com/r1cksec/misc/raw/main/binaries/csprecon -O /usr/local/bin/csprecon
chmod +x /usr/local/bin/csprecon
wget https://github.com/r1cksec/misc/raw/main/binaries/hakrawler -O /usr/local/bin/hakrawler
chmod +x /usr/local/bin/hakrawler

echo ""
echo "### Wget release binaries from corresponding repositories."
echo ""
wget https://github.com/OWASP/Amass/releases/download/v3.21.2/amass_linux_amd64.zip -O /tmp/amass.zip
unzip /tmp/amass.zip -d /tmp/amass
cp /tmp/amass/amass_linux_amd64/amass /usr/local/bin
chmod +x /usr/local/bin/amass

wget https://github.com/projectdiscovery/subfinder/releases/download/v2.5.5/subfinder_2.5.5_linux_amd64.zip -O /tmp/subfinder.zip
unzip /tmp/subfinder.zip -d /tmp/subfinder
cp /tmp/subfinder/subfinder /usr/local/bin
chmod +x /usr/local/bin/subfinder

wget https://github.com/mozilla/geckodriver/releases/download/v0.32.0/geckodriver-v0.32.0-linux64.tar.gz -O /tmp/geckodriver.tar.gz
gunzip /tmp/geckodriver.tar.gz
tar -xf /tmp/geckodriver.tar -C /usr/local/bin
chmod +x /usr/local/bin/geckodriver

wget https://github.com/tomnomnom/waybackurls/releases/download/v0.1.0/waybackurls-linux-amd64-0.1.0.tgz -O /tmp/wayback.tgz
tar -xf /tmp/wayback.tgz -C /usr/local/bin
chmod +x /usr/local/bin/waybackurls

wget https://github.com/zricethezav/gitleaks/releases/download/v8.15.2/gitleaks_8.15.2_linux_x64.tar.gz -O /tmp/gitleaks.tar.gz
tar -xf /tmp/gitleaks.tar.gz -C /tmp
mv /tmp/gitleaks /usr/local/bin
chmod +x /usr/local/bin/gitleaks

wget https://github.com/trufflesecurity/trufflehog/releases/download/v3.21.0/trufflehog_3.21.0_linux_amd64.tar.gz -O /tmp/truffleHog.tar.gz
tar -xf /tmp/truffleHog.tar.gz -C /tmp
mv /tmp/trufflehog /usr/local/bin
chmod +x /usr/local/bin/trufflehog

wget https://github.com/SecurityRiskAdvisors/letItGo/releases/download/v1.0/letItGo_v1.0_linux_amd64 -O /usr/local/bin/letItGo
chmod +x /usr/local/bin/letItGo

wget https://github.com/UKHomeOffice/repo-security-scanner/releases/download/0.4.0/scanrepo-0.4.0-linux-amd64.tar.gz -O /tmp/scanrepo.tar.gz
tar -xf /tmp/scanrepo.tar.gz -C /usr/local/bin
chmod +x /usr/local/bin/scanrepo

echo ""
echo "### Install Python dependency"
echo ""
git clone https://github.com/devanshbatham/FavFreak.git /tmp/FavFreak
cp /tmp/FavFreak/favfreak.py /usr/local/bin/favfreak
chmod +x /usr/local/bin/favfreak
pip3 install mmh3
pip3 install selenium

echo "Done"

