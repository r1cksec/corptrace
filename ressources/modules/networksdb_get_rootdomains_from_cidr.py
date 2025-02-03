#!/usr/bin/env python3

import urllib.parse
import sys
import os
import datetime
import time
from selenium.webdriver.common.by import By

if (len(sys.argv) != 2):
    print("usage: {} ipRange".format(sys.argv[0]))
    print("Visit networksdb.io and extract domains")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

# use nmap to calculate min and max host
timestamp = datetime.datetime.today().strftime("%d.%m.%Y_%H:%M:%S")
ipRange = sys.argv[1]
nmapOutFile = "/tmp/networksdb-get-domains" + timestamp
nmapCommand = "nmap -n -sL " + ipRange + " > " + nmapOutFile

# create temporary output file 
os.system(nmapCommand)
nmapFp = open(nmapOutFile, "r")
nmapContent = nmapFp.readlines()
nmapFp.close()
minIp = nmapContent[2].replace("Nmap scan report for ","")
maxIp = nmapContent[-2].replace("Nmap scan report for ","")
url = "https://networksdb.io/domains-in-network/" + minIp.replace("\n","") + "/" + maxIp.replace("\n","")

# remove temporary file
os.remove(nmapOutFile)

try:
    driver.get(url)
    time.sleep(10)

    allIps = {}

    # get all ips
    elements = driver.find_elements(By.TAG_NAME, "pre")

    for element in elements:
        ipElement = element.find_element(By.XPATH, "preceding-sibling::b[1]")

        if ipElement:
            ipAddress = ipElement.text.strip(":")

            # collect domains corresponding to IPv4
            domains = element.text.strip().split("\n")
            allIps[ipAddress] = domains

    # print results
    for ip, domains in allIps.items():
        print(ip)
        for domain in domains:
            print(domain)
        print("")
    
    driver.close()

except Exception as e:         
    print(e)
    driver.close()


