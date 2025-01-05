#!/usr/bin/env python3

import sys
import os
import ipaddress

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} ipRange ".format(sys.argv[0]))
    print("Run nmap and scan IP Range for port 443 and extract Subject Alternative Name")
    sys.exit(1)

nmapCommand = "nmap --min-rate 300 -sT --script /usr/share/nmap/scripts/ssl-cert.nse -Pn -p 443 -n --open -oN "
outFile = "/tmp/nmap-ssl-cert-" + sys.argv[1].replace("/","_") + ".nmap "
nmapCommand2 = sys.argv[1] + " > /dev/null"
os.system(nmapCommand + outFile + nmapCommand2)

# used to sort resulting domains unique
allDomains = []

# grep certificate commonName and alternative name for each host
with open("/tmp/nmap-ssl-cert-" + sys.argv[1].replace("/","_") + ".nmap") as nmapResult:
    for line in nmapResult:
        # grep for commonName
        if ("| ssl-cert: Subject: commonName=" in line):
            commonNameofCurrHostWithAppendix = line.split("ssl-cert: Subject: commonName=")

            # remove appendix
            commonNameofCurrHost = commonNameofCurrHostWithAppendix[1].split("/")
            cleanCurrCommonName = commonNameofCurrHost[0].replace("\n", "")
            cleanCurrCommonName = cleanCurrCommonName.replace("*.","")
            cleanCurrCommonName = cleanCurrCommonName.replace(".*","")
            allDomains.append(cleanCurrCommonName)

        # grep for Subject Alternative Name
        if ("| Subject Alternative Name: DNS:" in line):
            allSubjectAltName = line.split("DNS:")

            # get each Subject Alternative Name
            for subAltNameWithAppendix in allSubjectAltName:
                # remove appendix
                subAltName = subAltNameWithAppendix.split(",")

                # skip delimiter "| Subject Alternative Name:
                if ("| Subject Alternative Name:" in subAltName[0]):
                    continue

                cleanCurrCommonName = subAltName[0].replace("\n", "")
                cleanCurrCommonName = cleanCurrCommonName.replace("*.","")
                cleanCurrCommonName = cleanCurrCommonName.replace(".*","")
                allDomains.append(cleanCurrCommonName)

allFinalDomains = sorted(set(allDomains))

# print results
for currDom in allFinalDomains:
    try:
        # skip ipv4 addresses
        ipaddress.IPv4Address(currDom)
    except ipaddress.AddressValueError:
        print (currDom)

os.system("rm " + outFile)

