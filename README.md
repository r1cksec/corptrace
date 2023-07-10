# Thoth

Thoth is a modular framewok that automates the execution of tools during a reconnaissance assessment.
Using multithreading, several tasks are executed simultaneously.
The use of different modules can be adapted on the fly by using module names or risk level as a filter.
I wrote this tool primarily to automate my workflow, so I'm sure it's still buggy for some corner cases.
<br>
<br>
Note that running thoth repetitively in a short amount of time can lead to blocking of the IP address used, as thoth can query multiple APIs at the same time.
<br>
<br>
The core is the `modules.json` file, which contains the syntax of the executable commands.
Variables can also be stored in this configuration file, which are automatically included in the arguments of Argparse.

## Install
The setup script will install tool dependencies and insert the absolute path to the scripts into the `modules.json` file (only tested on kali).

```
sudo bash setup.sh
```

There is **no** update feature.
To update thoth, remove the old repository, git clone the current version and re-run the `setup.sh` file.

## Configuration
The `modules.json` file contains all modules that can be executed by thoth. <br>
A single module has the following structure:

```
{
    "name": "nameOfModule",
    "riskLevel": "riskLevelFrom1To4",
    "syntax": "commandSyntax <variable> > <outputFile> 2>&1",
},
```

### name, risklevel
The configuration can be extended as desired. <br>
However, it should be noted that the modules cannot have the same name.
<br>
<br>
Each module requires a risk level between 1 to 4.  <br>
The higher the level, the higher the probability that the module can cause damage or .
<br>

### syntax - variables
Strings inside `<...>` are interpreted as variables. <br>
The syntax must always end with an `> <outputFile> 2>&1` so that the output can be written to a file. <br>
<br>
It is possible to include custom variables. <br>
Custom variables are added to the arguments of Argparse. <br>
Camelcase notation sets the abbreviations for the Argparse's arguments.
<br>
<br>
Modules are only executed if all `<variables>` occurring in the syntax are given by the user. <br>
For example, the following module would add the value `domain (-d)` to the Argparse's arguments.

```    
{
    "name": "amass-intel-domain",
    "riskLevel": "2",
    "syntax": "amass intel -d <domain> > <outputFile> 2>&1"
},
```

## Help
```
usage: thoth.py [-h] -o OUTPUT [-e] [-v] [-t TIMEOUT] [-rl RISKLEVEL] [-ta THREADAMOUNT] [-em [EXCLUDEMODULES ...]] [-im [INCLUDEMODULES ...]] [-an ASNUMBER] [-cn COMPANYNAME] [-cr COPYRIGHT] [-d DOMAIN] [-df DOMAINFILE]
                [-gr GITHUBREPOSITORY] [-grl GITHUBREPOSITORYLOCAL] [-gid GOOGLEID] [-ir IPRANGE] [-u USER]

Automatic reconaissance.
Use at your own risk.
I do not take any responsibility for your actions!

Basic usage:
Print matching modules for a given domain:
./thoth.py -o /tmp/output -d example.com

Execute modules for given domain:
./thoth.py -o /tmp/output -d example.com -e

Only execute modules that contains at least one of the given substring in their name:
./thoth.py -o /tmp/output -d example.com -im amass -ir 192.168.1.3-9 -e

Execute modules up to risk level 4, use 8 threads and increase timeout to 35 minutes:
./thoth.py -o /tmp/output -d example.com -rl 4 -ta 8 -t 2100 -an AS8560

options:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        path to output directory
  -e, --execute         execute matching commands
  -v, --verbose         print full command
  -t TIMEOUT, --timeout TIMEOUT
                        maximal time that a single thread is allowed to run in seconds (default 1200)
  -rl RISKLEVEL, --riskLevel RISKLEVEL
                        set maximal riskLevel for modules (possible values 1-4, 2 is default)
  -ta THREADAMOUNT, --threadAmount THREADAMOUNT
                        the amount of parallel running threads (default 5)
  -em [EXCLUDEMODULES ...], --exludeModules [EXCLUDEMODULES ...]
                        modules that will be excluded (exclude ovewrites include)
  -im [INCLUDEMODULES ...], --includeModules [INCLUDEMODULES ...]
                        modules that will be included
  -an ASNUMBER, --asNumber ASNUMBER
  -cn COMPANYNAME, --companyName COMPANYNAME
  -cr COPYRIGHT, --copyRight COPYRIGHT
  -d DOMAIN, --domain DOMAIN
  -df DOMAINFILE, --domainFile DOMAINFILE
  -gr GITHUBREPOSITORY, --githubRepository GITHUBREPOSITORY
  -grl GITHUBREPOSITORYLOCAL, --githubRepositoryLocal GITHUBREPOSITORYLOCAL
  -gid GOOGLEID, --googleID GOOGLEID
  -ir IPRANGE, --ipRange IPRANGE
  -u USER, --user USER
```

## Demo (old)

<p align="center">
<img src="https://github.com/r1cksec/thoth/blob/master/demo.gif"/>
</p>

## Result Structure (old)
```
out
├── csprecon
│   └── csprecon_example.com
├── get-asn
│   └── get-asn_example.com
├── get-dns-records
│   └── get-dns-records_example.com
├── get-mails
│   └── get-mails_example.com
├── letItGo
│   └── letItGo_example.com
└── subfinder
    └── subfinder_example.com
```

## Currently included Modules

**Sources**

* <https://github.com/blechschmidt/massdns>
* <https://github.com/darkoperator/dnsrecon>
* <https://github.com/devanshbatham/FavFreak>
* <https://github.com/dhn/spk>
* <https://github.com/edoardottt/csprecon>
* <https://github.com/hakluke/hakrawler>
* <https://github.com/MattKeeley/Spoofy>
* <https://github.com/OWASP/Amass>
* <https://github.com/projectdiscovery/subfinder>
* <https://github.com/r1cksec/thoth/tree/master/scripts/completedns-get-ns-history>
* <https://github.com/r1cksec/thoth/tree/master/scripts/dnslytics-get-rootdomains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/get-dns-records>
* <https://github.com/r1cksec/thoth/tree/master/scripts/get-github-repos>
* <https://github.com/r1cksec/thoth/tree/master/scripts/get-ips-from-asn>
* <https://github.com/r1cksec/thoth/tree/master/scripts/google-get-linkedIn-employees>
* <https://github.com/r1cksec/thoth/tree/master/scripts/google-get-pdf-metadata>
* <https://github.com/r1cksec/thoth/tree/master/scripts/google-get-rootdomains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/grepapp-get-github-users>
* <https://github.com/r1cksec/thoth/tree/master/scripts/grep-through-commits>
* <https://github.com/r1cksec/thoth/tree/master/scripts/hackertarget-get-rootdomains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/hakrawler-ip-range>
* <https://github.com/r1cksec/thoth/tree/master/scripts/handelsregister-get-company-names>
* <https://github.com/r1cksec/thoth/tree/master/scripts/nmap-get-tls-alternative-names>
* <https://github.com/r1cksec/thoth/tree/master/scripts/northdata-get-company-names>
* <https://github.com/r1cksec/thoth/tree/master/scripts/skymem-get-mails>
* <https://github.com/r1cksec/thoth/tree/master/scripts/sort-domains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/sort-rootdomains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/spyonweb-get-rootdomains>
* <https://github.com/r1cksec/thoth/tree/master/scripts/tld-discovery>
* <https://github.com/r1cksec/thoth/tree/master/scripts/tmdb-get-company-names>
* <https://github.com/SecurityRiskAdvisors/letitgo>
* <https://github.com/trufflesecurity/truffleHog>
* <https://github.com/UKHomeOffice/repo-security-scanner>
* <https://github.com/zricethezav/gitleaks>

#

https://en.wikipedia.org/wiki/Thoth

<p align="center">
<img src="https://user-images.githubusercontent.com/77610058/224850581-5dcf9442-100b-4dcb-99e8-0de3df570415.png" width=50%/>
</p>

