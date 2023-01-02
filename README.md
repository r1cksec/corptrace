# Autorec

Autorec is a very modular tool that automates the execution of tools during a reconnaissance assessment.
Using multithreading, several tools are executed simultaneously.
The use of different modules can be adapted on the fly by using module names or risk level as a filter.
<br>
<br>
The core is the `modules.json` file, which contains the syntax of the executable commands.
Variables can also be stored in this configuration file, which are automatically included in the arguments of Argparse.

## Requirements
- Debian based operating system

## Install
The setup script will install tool dependencies and insert the absolute path to the scripts into the `modules.json` file.

```
sudo bash setup.sh
```

## Configuration
The `modules.json` file contains all modules that can be executed by autorec. <br>
The modules have the following structure:

```
{
    "name": "nameOfModule",
    "riskLevel": "riskLevelAsInteger",
    "syntax": "commandSyntax <variable> > <outputFile> 2>&1",
},
```

### name, risklevel
The configuration can be extended as desired. <br>
However, it should be noted that the modules cannot have the same name.
<br>
<br>
Each module requires a risk level between 1 to 4.  <br>
The higher the level, the higher the probability that the module can cause damage.
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
    "syntax": "amass intel -d <domain> -whois > <outputFile> 2>&1"
},
```

## Help
```
usage: autorec.py [-h] -o OUTPUT [-e] [-v] [-t TIMEOUT] [-rl RISKLEVEL] [-ta THREADAMOUNT]
                  [-em [EXCLUDEMODULES ...]] [-im [INCLUDEMODULES ...]] [-an ASNUMBER]
                  [-cn COMPANYNAME] [-d DOMAIN] [-df DOMAINFILE] [-gr GITHUBREPOSITORY]
                  [-grl GITHUBREPOSITORYLOCAL] [-gu GITHUBUSER] [-ir IPRANGE] [-w WORD]

Automatic reconaissance.
Use at your own risk.
I do not take any responsibility for your actions!

Basic usage:
Print matching modules for a given domain:
./autorec.py -o /tmp/output -d example.com

Execute modules for given domain:
./autorec.py -o /tmp/output -d example.com -e

Only execute modules that contains at least one of the given substring in their name:
./autorec.py -o /tmp/output -d example.com -im amass -ir 192.168.1.3-9 -e

Execute modules with higher risk level, use more threads and increase timeout:
./autorec.py -o /tmp/output -d example.com -rl 4 -ta 8 -t 3000 -an AS8560

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
  -d DOMAIN, --domain DOMAIN
  -df DOMAINFILE, --domainFile DOMAINFILE
  -gr GITHUBREPOSITORY, --githubRepository GITHUBREPOSITORY
  -grl GITHUBREPOSITORYLOCAL, --githubRepositoryLocal GITHUBREPOSITORYLOCAL
  -gu GITHUBUSER, --githubUser GITHUBUSER
  -ir IPRANGE, --ipRange IPRANGE
  -w WORD, --word WORD
```

## Demo
![](https://github.com/r1cksec/autorec/blob/master/demo.gif)

## Result Structure 
```
out
├── dnsrecon-zonetransfer
│   └── dnsrecon-zonetransfer_example.com
├── dnsrecon-zonewalk
│   └── dnsrecon-zonewalk_example.com
├── get-asn
│   └── get-asn_example.com
├── hakrawler
│   └── hakrawler_example.com
├── subfinder
│   └── subfinder_example.com
└── waybackurls
    └── waybackurls_example.com
```

## Currently included Modules

**Sources**

* <https://github.com/blechschmidt/massdns>
* <https://github.com/darkoperator/dnsrecon>
* <https://github.com/devanshbatham/FavFreak>
* <https://github.com/dhn/spk>
* <https://github.com/edoardottt/csprecon>
* <https://github.com/hakluke/hakrawler>
* <https://github.com/OWASP/Amass>
* <https://github.com/projectdiscovery/subfinder>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-cert-domains-from-ip-range>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-dns-records>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-github-repos>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-grep-app>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-ips-from-asn>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-mails>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-netblocks>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-page-owner>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-title>
* <https://github.com/r1cksec/autorec/tree/master/scripts/get-whois-hoster>
* <https://github.com/r1cksec/autorec/tree/master/scripts/grep-through-commits>
* <https://github.com/r1cksec/autorec/tree/master/scripts/hakrawler-ip-range>
* <https://github.com/r1cksec/autorec/tree/master/scripts/north-scraper>
* <https://github.com/r1cksec/autorec/tree/master/scripts/search-google>
* <https://github.com/r1cksec/autorec/tree/master/scripts/tld-discovery>
* <https://github.com/SecurityRiskAdvisors/letitgo>
* <https://github.com/tomnomnom/waybackurls>
* <https://github.com/trufflesecurity/truffleHog>
* <https://github.com/UKHomeOffice/repo-security-scanner>
* <https://github.com/zricethezav/gitleaks>

