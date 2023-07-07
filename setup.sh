#!/bin/bash

# stop on error
set -e

# stop on undefined
set -u

if [ "$EUID" -ne 0 ]
then
    echo "Please run script using sudo"
    exit
fi

echo ""
echo "### Kali Setup Script"
echo ""
sleep 1

# Write path to scripts into module.json file
pathToScriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
sed -i "s|REPLACEME|${pathToScriptDir}|g" "${pathToScriptDir}/modules.json"
pathToHomeDir=$(echo ${pathToScriptDir} | awk -F "/" '{print $1"/"$2"/"$3}')
userName=$(echo ${pathToScriptDir} | awk -F "/" '{print $3}')

echo ""
echo "### APT Install"
apt install -y dnsrecon git wget python3 python3-pip whois curl nmap libimage-exiftool-perl

echo ""
echo "### Install Golang tools."
echo ""

# Download golang
wget https://golang.google.cn/dl/go1.20.3.linux-amd64.tar.gz -O /tmp/go.tar.gz
tar -xf /tmp/go.tar.gz -C /tmp
rm -r /tmp/go.tar.gz
export GOPATH=/tmp

if ! [ -x "$(command -v spk)" ]
then
    /tmp/go/bin/go install github.com/dhn/spk@latest
    mv /tmp/bin/spk /usr/local/bin
    chmod +x /usr/local/bin/spk
else
    echo "spk is installed"
fi

if ! [ -x "$(command -v csprecon)" ]
then
    /tmp/go/bin/go install github.com/edoardottt/csprecon/cmd/csprecon@latest
    mv /tmp/bin/csprecon /usr/local/bin
    chmod +x /usr/local/bin/csprecon
else
    echo "csprecon is installed"
fi

if ! [ -x "$(command -v hakrawler)" ]
then
    /tmp/go/bin/go install github.com/hakluke/hakrawler@latest
    mv /tmp/bin/hakrawler /usr/local/bin
    chmod +x /usr/local/bin/hakrawler
else
    echo "hakrawler is installed"
fi

if ! [ -x "$(command -v subfinder)" ]
then
    /tmp/go/bin/go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    mv /tmp/bin/subfinder /usr/local/bin
    chmod +x /usr/local/bin/subfinder
else
    echo "subfinder is installed"
fi

echo ""
echo "### Compile Binary from Git."
echo ""

if ! [ -x "$(command -v massdns)" ]
then
    git clone https://github.com/blechschmidt/massdns.git /tmp/massdns
    cd /tmp/massdns && make
    mv /tmp/massdns/bin/massdns /usr/local/bin
    chmod +x /usr/local/bin/massdns
    rm -r /tmp/massdns
else
    echo "massdns is installed"
fi

echo ""
echo "### Wget compiled binaries."
echo ""

if ! [ -x "$(command -v amass)" ]
then
    wget https://github.com/OWASP/Amass/releases/download/v3.22.0/amass_linux_amd64.zip -O /tmp/amass.zip
    unzip /tmp/amass.zip -d /tmp/amass
    mv /tmp/amass/amass_linux_amd64/amass /usr/local/bin
    chmod +x /usr/local/bin/amass
    rm -rf /tmp/amass.zip /tmp/amass
else
    echo "amass is installed"
fi

if ! [ -x "$(command -v geckodriver)" ]
then
    wget https://github.com/mozilla/geckodriver/releases/download/v0.32.0/geckodriver-v0.32.0-linux64.tar.gz -O /tmp/geckodriver.tar.gz
    tar -xf /tmp/geckodriver.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/geckodriver
    rm /tmp/geckodriver.tar.gz
else
    echo "geckodriver is installed"
fi

if ! [ -x "$(command -v gitleaks)" ]
then
    wget https://github.com/zricethezav/gitleaks/releases/download/v8.15.2/gitleaks_8.15.2_linux_x64.tar.gz -O /tmp/gitleaks.tar.gz
    tar -xf /tmp/gitleaks.tar.gz -C /tmp
    mv /tmp/gitleaks /usr/local/bin
    chmod +x /usr/local/bin/gitleaks
    rm /tmp/README.md /tmp/LICENSE /tmp/gitleaks.tar.gz
else
    echo "gitleaks is installed"
fi

if ! [ -x "$(command -v trufflehog)" ]
then
    wget https://github.com/trufflesecurity/trufflehog/releases/download/v3.21.0/trufflehog_3.21.0_linux_amd64.tar.gz -O /tmp/truffleHog.tar.gz
    tar -xf /tmp/truffleHog.tar.gz -C /tmp
    mv /tmp/trufflehog /usr/local/bin
    chmod +x /usr/local/bin/trufflehog
    rm /tmp/README.md /tmp/LICENSE /tmp/truffleHog.tar.gz
else
    echo "trufflehog is installed"
fi

if ! [ -x "$(command -v letItGo)" ]
then
    wget https://github.com/SecurityRiskAdvisors/letItGo/releases/download/v1.0/letItGo_v1.0_linux_amd64 -O /usr/local/bin/letItGo
    chmod +x /usr/local/bin/letItGo
else
    echo "letItGo is installed"
fi

if ! [ -x "$(command -v scanrepo)" ]
then
    wget https://github.com/UKHomeOffice/repo-security-scanner/releases/download/0.4.0/scanrepo-0.4.0-linux-amd64.tar.gz -O /tmp/scanrepo.tar.gz
    tar -xf /tmp/scanrepo.tar.gz -C /usr/local/bin
    chmod +x /usr/local/bin/scanrepo
    rm /tmp/scanrepo.tar.gz
else
    echo "scanrepo is installed"
fi

echo ""
echo "### Install Python dependencies"
echo ""
echo "Install python dependencies as ${userName} without virtual environment ..."
echo "Alternatively you have to install favfreak and spoofy yourself."
echo "Do you want to install python dependencies without virtual environment (y/anything else n)?"

read str

if [ "${str}" == "y" ]
then
    if ! [ -x "$(command -v favfreak)" ]
    then
        cd /tmp
        git clone https://github.com/devanshbatham/FavFreak.git /tmp/FavFreak
        cp /tmp/FavFreak/favfreak.py /usr/local/bin/favfreak
        chmod +x /usr/local/bin/favfreak
        sudo -su ${userName} pip3 install -r /tmp/FavFreak/requirements.txt
        rm -r /tmp/FavFreak
    else
        echo "FavFreak is installed"
    fi

    if ! [ -x "$(command -v spoofy)" ]
    then
        cd /tmp
        git clone https://github.com/MattKeeley/Spoofy
        sudo -su ${userName} pip3 install -r /tmp/Spoofy/requirements.txt
        sudo -su ${userName} pip3 install libs
        cp /tmp/Spoofy/spoofy.py /usr/local/bin/spoofy
        cp -r /tmp/Spoofy/libs /usr/local/bin/libs
        chmod +x /usr/local/bin/spoofy
        rm -r /tmp/Spoofy
    else
        echo "spoofy is installed"
    fi

    pip3 install selenium
fi

echo "Done"

