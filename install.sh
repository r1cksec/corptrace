#!/bin/bash

# stop on error
set -e

# stop on undefined
set -u

echo ""
echo "### Setup Script"
echo "Use 'bash install -force' to reinstall each tool."
echo ""

# check if installation is forced
if [ ${#} -eq 1 ]
then
    if [ "${1}" == "-force" ]
    then
        force="1"
    else
        force="0"
    fi
else
    force="0"
fi

# define variables
pathToRepo="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
pathToRessources="${pathToRepo}/ressources"
pathToScripts="${pathToRepo}/ressources/modules"
pathToTemplates="${pathToRepo}/ressources/templates"
pathToBuild="${pathToRepo}/build"
pathToConfig="${pathToBuild}/config.json"
pathToTemp="${pathToBuild}/temp"
pathToGit="${pathToBuild}/git"
pathToPython="${pathToBuild}/python-env"

# check if the script is run using sudo
if [ -n "${SUDO_USER:-}" ]
then
    pathToHomeDir="/home/${SUDO_USER}"
else
    pathToHomeDir="$HOME"
fi

# create temporay path
if [ ! -d ${pathToTemp} ]
then
    mkdir ${pathToTemp}
else
    sudo rm -rf ${pathToTemp}
    mkdir ${pathToTemp}
fi

echo ""
echo "### APT Install"
echo ""
sudo apt update

# install basic packets
sudo apt install -y git wget python3 python3-venv python3-pip whois curl nmap libimage-exiftool-perl jq dnstwist bc

echo ""
echo "### Write modules.json"
echo ""

# check if all keys are empty
if jq -e 'map(. == "") | all' ${pathToConfig} > /dev/null
then
    echo "No API key in ${pathToConfig} found!"
    echo "Using API keys leads to more extensive results."
    echo "The installation process can later be repeated using additional API keys."
    echo "Do you want to continue the installation without using API keys? (y/everything else for no)."

    read answer
    if [ "${answer}" != "y" ]
    then
        echo "Abort installation"
        exit
    fi
fi

# read api keys
bevigilKey=$(jq -r '.bevigil_com' ${pathToConfig})
bufferoverKey=$(jq -r '.bufferover_run' ${pathToConfig})
fullhuntKey=$(jq -r '.fullhunt_io' ${pathToConfig})
githubKey=$(jq -r '.github_com' ${pathToConfig})
grayhatwarfareKey=$(jq -r '.grayhatwarfare_com' ${pathToConfig})
hunterKey=$(jq -r '.hunter_io' ${pathToConfig})
leakixKey=$(jq -r '.leakix_net' ${pathToConfig})
netlasKey=$(jq -r '.netlas_io' ${pathToConfig})
networksdbKey=$(jq -r '.networksdb_io' ${pathToConfig})
projectdiscoveryKey=$(jq -r '.projectdiscovery_io_key' ${pathToConfig})
projectdiscoveryUser=$(jq -r '.projectdiscovery_io_user' ${pathToConfig})
pugreconKey=$(jq -r '.pugrecon_com' ${pathToConfig})
rsecloudKey=$(jq -r '.rsecloud_com' ${pathToConfig})
robtexKey=$(jq -r '.robtex_com' ${pathToConfig})
securitytrailsKey=$(jq -r '.securitytrails_com' ${pathToConfig})
shodanKey=$(jq -r '.shodan_io' ${pathToConfig})
sslmateKey=$(jq -r '.sslmate_com' ${pathToConfig})
tombaKeya=$(jq -r '.tomba_io_ta' ${pathToConfig})
tombaKeys=$(jq -r '.tomba_io_ts' ${pathToConfig})
urlscanKey=$(jq -r '.urlscan_io' ${pathToConfig})
validinKey=$(jq -r '.validin_com' ${pathToConfig})
virustotalKey=$(jq -r '.virustotal_com' ${pathToConfig})
xingPassword=$(jq -r '.xing_com_password' ${pathToConfig})
xingUser=$(jq -r '.xing_com_user' ${pathToConfig})
zoomeyeKey=$(jq -r '.zoomeye_hk' ${pathToConfig})

# ' inside xing password
if [[ "${xingPassword}" == *"'"* ]]
then
    echo "No ' inside xing password allowed."
    exit 1
fi

# write config for subfinder
cat > ${pathToBuild}/subfinder.config << EOL
bevigil: [${bevigilKey}]
bufferover: [${bufferoverKey}]
certspotter: [${sslmateKey}]
chaos: [${projectdiscoveryKey}]
fullhunt: [${fullhuntKey}]
github: [${githubKey}]
hunter: [${hunterKey}]
leakix: [${leakixKey}]
netlas: [${netlasKey}]
pugrecon: [${pugreconKey}]
rsecloud: [${rsecloudKey}]
robtex: [${robtexKey}]
securitytrails: [${securitytrailsKey}]
shodan: [${shodanKey}]
virustotal: [${virustotalKey}]
zoomeyeapi: [${zoomeyeKey}]
EOL

# write config for dnsx
if [ -n "${projectdiscoveryKey}" ]
then
    if [ ! -d "${pathToHomeDir}/.pdcp" ]
    then
        mkdir "${pathToHomeDir}/.pdcp"
    fi
    
    cat > ${pathToHomeDir}/.pdcp/credentials.yaml << EOL
- username: $(echo "${projectdiscoveryUser}" | cut -d "@" -f 1)
  email: ${projectdiscoveryUser}
  api-key: ${projectdiscoveryKey}
  server: https://api.projectdiscovery.io
EOL
fi

# write api keys, passwords and absolute paths to modules.json
sed -e "s|REPLACE-GITHUB-APIKEY|${githubKey}|g" \
    -e "s|REPLACE-GRAYHATWARFARE-APIKEY|${grayhatwarfareKey}|g" \
    -e "s|REPLACE-HUNTER-APIKEY|${hunterKey}|g" \
    -e "s|REPLACE-RESSOURCE-PATH|${pathToRessources}|g" \
    -e "s|REPLACE-NETWORKSDB-APIKEY|${networksdbKey}|g" \
    -e "s|REPLACE-ROBTEX-APIKEY|${robtexKey}|g" \
    -e "s|REPLACE-SECURITYTRAILS-APIKEY|${securitytrailsKey}|g" \
    -e "s|REPLACE-SHODAN-APIKEY|${shodanKey}|g" \
    -e "s|REPLACE-SUBFINDER-CONFIG|${pathToBuild}/subfinder.config|g" \
    -e "s|REPLACE-TOMBATA-APIKEY|${tombaKeya}|g" \
    -e "s|REPLACE-TOMBATS-APIKEY|${tombaKeys}|g" \
    -e "s|REPLACE-URLSCAN-APIKEY|${urlscanKey}|g" \
    -e "s|REPLACE-VALIDIN-APIKEY|${validinKey}|g" \
    -e "s|REPLACE-XING-USER|${xingUser}|g" \
    -e "s|REPLACE-XING-PASSWORD|${xingPassword}|g" \
    -e "s|REPLACE-ZOOMEYE-APIKEY|${zoomeyeKey}|g" \
       "${pathToTemplates}/modules.json" > "${pathToTemp}/modules.json"

# last line in modules.json should not contain an API key, because if key is empty, the line will be removed and the JSON syntax is broken
grep -v " '' " "${pathToTemp}/modules.json" > ${pathToBuild}/modules.json
echo "Done"

echo ""
echo "### Install Golang tools."
echo ""

# download golang
wget https://go.dev/dl/go1.23.5.linux-amd64.tar.gz -O ${pathToTemp}/go.tar.gz
tar -xf ${pathToTemp}/go.tar.gz -C ${pathToTemp}
rm -r ${pathToTemp}/go.tar.gz
export GOPATH=${pathToTemp}

if ! [ -x "$(command -v spk)" ] || [ "${force}" == "1" ]
then
    ${pathToTemp}/go/bin/go install github.com/dhn/spk@latest
    chmod +x ${pathToTemp}/bin/spk
    sudo mv ${pathToTemp}/bin/spk /usr/local/bin
else
    echo "spk is installed"
fi

if ! [ -x "$(command -v csprecon)" ] || [ "${force}" == "1" ]
then
    ${pathToTemp}/go/bin/go install github.com/edoardottt/csprecon/cmd/csprecon@latest
    chmod +x ${pathToTemp}/bin/csprecon
    sudo mv ${pathToTemp}/bin/csprecon /usr/local/bin
else
    echo "csprecon is installed"
fi

if ! [ -x "$(command -v subfinder)" ] || [ "${force}" == "1" ]
then
    ${pathToTemp}/go/bin/go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    chmod +x ${pathToTemp}/bin/subfinder
    sudo mv ${pathToTemp}/bin/subfinder /usr/local/bin
else
    echo "subfinder is installed"
fi

if ! [ -x "$(command -v dnsx)" ] || [ "${force}" == "1" ]
then
    ${pathToTemp}/go/bin/go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    chmod +x ${pathToTemp}/bin/dnsx
    sudo mv ${pathToTemp}/bin/dnsx /usr/local/bin
else
    echo "dnsx is installed"
fi

echo ""
echo "### Compile Binary from Git."
echo ""

git clone https://github.com/blechschmidt/massdns.git ${pathToTemp}/massdns
if ! [ -x "$(command -v massdns)" ] || [ "${force}" == "1" ]
then
    cd ${pathToTemp}/massdns && make
    chmod +x ${pathToTemp}/massdns/bin/massdns
    sudo mv ${pathToTemp}/massdns/bin/massdns /usr/local/bin
    cd -
    rm -rf ${pathToTemp}/massdns
else
    echo "massdns is installed"
fi

echo ""
echo "### Wget compiled binaries."
echo ""

if ! [ -x "$(command -v geckodriver)" ] || [ "${force}" == "1" ]
then
    latestGeckodriver=$(curl -sL https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r ".tag_name")
    wget "https://github.com/mozilla/geckodriver/releases/download/${latestGeckodriver}/geckodriver-${latestGeckodriver}-linux64.tar.gz" -O ${pathToTemp}/geckodriver.tar.gz
    tar -xf ${pathToTemp}/geckodriver.tar.gz -C ${pathToTemp}
    chmod +x ${pathToTemp}/geckodriver
    sudo mv ${pathToTemp}/geckodriver /usr/local/bin
    rm ${pathToTemp}/geckodriver.tar.gz
else
    echo "geckodriver is installed"
fi

if ! [ -x "$(command -v gitleaks)" ] || [ "${force}" == "1" ]
then
    latestGitleaks=$(curl -sL https://api.github.com/repos/gitleaks/gitleaks/releases/latest | jq -r ".tag_name")
    latestGitleaksNoV=$(echo ${latestGitleaks} | sed "s/v//")
    wget "https://github.com/gitleaks/gitleaks/releases/download/${latestGitleaks}/gitleaks_${latestGitleaksNoV}_linux_x64.tar.gz" -O ${pathToTemp}/gitleaks.tar.gz
    tar -xf ${pathToTemp}/gitleaks.tar.gz -C ${pathToTemp}
    chmod +x ${pathToTemp}/gitleaks
    sudo mv ${pathToTemp}/gitleaks /usr/local/bin
    rm ${pathToTemp}/README.md ${pathToTemp}/LICENSE ${pathToTemp}/gitleaks.tar.gz
else
    echo "gitleaks is installed"
fi

if ! [ -x "$(command -v trufflehog)" ] || [ "${force}" == "1" ]
then
    latestTruffleHog=$(curl -sL https://api.github.com/repos/trufflesecurity/trufflehog/releases/latest | jq -r ".tag_name")
    latestTruffleHogNoV=$(echo ${latestTruffleHog} | sed "s/v//")
    wget "https://github.com/trufflesecurity/trufflehog/releases/download/${latestTruffleHog}/trufflehog_${latestTruffleHogNoV}_linux_amd64.tar.gz" -O ${pathToTemp}/truffleHog.tar.gz
    tar -xf ${pathToTemp}/truffleHog.tar.gz -C ${pathToTemp}
    chmod +x ${pathToTemp}/trufflehog
    sudo mv ${pathToTemp}/trufflehog /usr/local/bin
    rm ${pathToTemp}/README.md ${pathToTemp}/LICENSE ${pathToTemp}/truffleHog.tar.gz
else
    echo "trufflehog is installed"
fi

if ! [ -x "$(command -v noseyparker)" ] || [ "${force}" == "1" ]
then
    latestNoseyparker=$(curl -sL https://api.github.com/repos/praetorian-inc/noseyparker/releases/latest | jq -r ".tag_name")
    wget "https://github.com/praetorian-inc/noseyparker/releases/download/${latestNoseyparker}/noseyparker-${latestNoseyparker}-x86_64-unknown-linux-gnu.tar.gz" -O ${pathToTemp}/noseyparker-x86_64-unknown-linux-gnu.tar.gz
    # prevent directory "bin" conflict with "go install" 
    mkdir ${pathToTemp}/noseyparker
    tar -xf ${pathToTemp}/noseyparker-x86_64-unknown-linux-gnu.tar.gz -C ${pathToTemp}/noseyparker
    chmod +x ${pathToTemp}/noseyparker/bin/noseyparker
    sudo mv ${pathToTemp}/noseyparker/bin/noseyparker /usr/local/bin
else
    echo "noseyparker is installed"
fi

echo ""
echo "### Install Python dependencies"
echo ""

# generate python environment
python3 -m venv ${pathToPython}
source ${pathToPython}/bin/activate

# prepare git directory
if [ ! -d ${pathToGit} ]
then
    mkdir ${pathToGit}
else
    rm -rf ${pathToGit}
    mkdir ${pathToGit}
fi

git clone https://github.com/punk-security/dnsreaper ${pathToGit}/dnsreaper
if ! [ -x "$(command -v dnsreaper)" ] || [ "${force}" == "1" ]
then
    ${pathToPython}/bin/pip3 install -r ${pathToGit}/dnsreaper/requirements.txt
    echo "cd ${pathToGit}/dnsreaper && ${pathToPython}/bin/python3 main.py \"\$@\"" > ${pathToTemp}/dnsreaper
    chmod +x ${pathToTemp}/dnsreaper
    sudo mv ${pathToTemp}/dnsreaper /usr/local/bin
else
    echo "dnsreaper is installed"
fi

git clone https://github.com/MattKeeley/Spoofy ${pathToGit}/Spoofy
if ! [ -x "$(command -v spoofy)" ] || [ "${force}" == "1" ]
then
    ${pathToPython}/bin/pip3 install -r ${pathToGit}/Spoofy/requirements.txt
    echo "cd ${pathToGit}/Spoofy && ${pathToPython}/bin/python3 spoofy.py \"\$@\"" > ${pathToTemp}/spoofy
    chmod +x ${pathToTemp}/spoofy
    sudo mv ${pathToTemp}/spoofy /usr/local/bin
else
    echo "spoofy is installed"
fi

git clone https://github.com/devanshbatham/FavFreak.git ${pathToGit}/FavFreak
if ! [ -x "$(command -v favfreak)" ] || [ "${force}" == "1" ]
then
    ${pathToPython}/bin/pip3 install -r ${pathToGit}/FavFreak/requirements.txt
    echo "cd ${pathToGit}/FavFreak && ${pathToPython}/bin/python3 favfreak.py \"\$@\"" > ${pathToTemp}/favfreak
    chmod +x ${pathToTemp}/favfreak
    sudo mv ${pathToTemp}/favfreak /usr/local/bin
else
    echo "favfreak is installed"
fi

echo ""
echo "Copy custom scripts to /usr/local/bin"

# add custom scripts to $PATH
allCustomScripts=$(ls ${pathToScripts})

for scriptName in ${allCustomScripts}
do
    fileNameNoExt=$(basename "${scriptName}" | cut -d. -f 1)
    fileExtension=$(basename "${scriptName}" | cut -d. -f 2)
    
    if [ "${fileExtension}" == "py" ]
    then
        # add absolute path to python environment
        echo "${pathToPython}/bin/python3 ${pathToScripts}/${scriptName} \"\$@\"" > ${pathToTemp}/${fileNameNoExt}
        chmod +x ${pathToTemp}/${fileNameNoExt}
        sudo mv ${pathToTemp}/${fileNameNoExt} /usr/local/bin
    elif [ "${fileExtension}" == "sh" ]
    then
        cp ${pathToScripts}/${scriptName} ${pathToTemp}/${fileNameNoExt}
        chmod +x ${pathToTemp}/${fileNameNoExt}
        sudo mv ${pathToTemp}/${fileNameNoExt} /usr/local/bin
    fi
done

# install selenium and lxml
${pathToPython}/bin/pip3 install -U selenium lxml requests
deactivate

# delete temporary directory
sudo rm -rf ${pathToTemp}
echo ""
echo "Done"


