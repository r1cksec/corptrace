#!/usr/bin/env python3

import sys
import time
import os
from selenium.webdriver.common.by import By

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} gid".format(sys.argv[0]))
    print("ID can either be Google Adsense (pub-X) or Google Analytics (ua-X)")
    print("Visit dnslytics.com and extract domains connected to google id")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

gid = sys.argv[1].lower()

# check id format
if ("ua-" not in gid and "pub-" not in gid):
    print("Wrong format for gid!")
    driver.close()
    exit(1)

driver.get("https://search.dnslytics.com/search?q=html.tag:" + gid + "&d=domains")

domains = driver.find_elements(By.XPATH, './/h4')

for domain in domains:
    print(domain.text)

