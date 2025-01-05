#!/usr/bin/env python3

from selenium.webdriver.common.by import By
import urllib.parse
import sys
import os

if (len(sys.argv) != 2):
    print("usage: {} domain".format(sys.argv[0]))
    print("Visit skymem.info and extract e-mail addresses")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

allMails = []

domain = urllib.parse.quote(sys.argv[1])
try:
    driver.get("https://www.skymem.info/srch?q=" + domain)
    
    allSkymemMails = []
    secondPage = ""
    
    elems = driver.find_elements(By.XPATH, "//a[@href]")
    
    for elem in elems:
        href = elem.get_attribute("href")
    
        if (domain in href):
            allSkymemMails.append(href)
    
        if ("/domain/" in href):
            secondPage = href
    
    if (secondPage == ""):
        print("No results found for: " + sys.argv[1])
        exit(0)
    
    driver.get(secondPage)
    elements = driver.find_elements(By.XPATH, "//a[@href]")
    
    for e in elements:
        ref = e.get_attribute("href")
    
        if (domain in ref):
            allSkymemMails.append(ref)
    
        if ("/domain/" in ref):
            secondPage = ref
    
    driver.close()

except Exception as e:         
    print(e)
    driver.close()

# sort results
for skymemLink in allSkymemMails:
    if ("@" + domain in skymemLink):
        splittedSkymen = skymemLink.split("?q=")
        splitSkymem = splittedSkymen[1].split("'")
        allMails.append(splittedSkymen[1])

allMailsSorted = sorted(set(allMails))

# print results
for m in allMailsSorted:
    print(m)


