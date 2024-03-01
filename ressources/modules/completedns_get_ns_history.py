#!/usr/bin/env python3

import os
from lxml import etree
from os import path
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import sys
import time

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} domain".format(sys.argv[0]))
    print("Visit completedns.com and extract nameserver history")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

rootdomain = sys.argv[1]
url = "https://completedns.com/dns-history"
driver.get(url)

time.sleep(3)

# search for domain
textField = driver.find_elements(By.ID, "domain")
textField[0].send_keys(rootdomain)
textField[0].send_keys(Keys.RETURN)

time.sleep(8)

sourceCode = driver.page_source
tree = etree.HTML(sourceCode)

# check if top level domain is supported
try:
    # used as flags to control code logic
    dateLine = ""
    nameLine = ""
    yearDone = "0"
    dateDone = "0"
    
    # get historical nameserver
    for element in tree.iterdescendants():
    
        if (element.tag == "div"):
            className = element.get("class")
    
            # get date
            if (className is not None):
                if (element.text is not None):
                    dateElement = element.text.strip()
    
                    # only get start year of timeline
                    if ("year" in className and dateLine == ""):
                        dateLine = dateLine + dateElement.replace("\n","") + " "
                        yearDone = "1"
    
                    # only get start month of timeline
                    if ("month-day" in className and dateDone == "0"):
                        dateLine = dateLine + dateElement.replace("\n","")
                        dateDone = "1"
    
                    # flush variables
                    if ("year" in className and yearDone == "1"):
                        yearDone = "0"
                        dateDone = "0"
    
                    # append element if nameLine contains nameserver strings
                    if (nameLine != ""):
                        print(dateLine)
                        print(nameLine)
                        print("")
    
                        # flush variables
                        nameLine = ""
                        dateLine = ""
 
            # get nameserver
            if (className is not None and "col-md-6" in className):
                # only print class "col-md-6" if it contains <b>Nameservers</b>
                if (any(child.tag == "b" and child.text == "Nameservers" for child in element.iter())):
                    for child_element in element.xpath(".//text()"):
                        if (child_element.strip()):
                            content = child_element.strip()
                            if ("Nameservers" != content and content != ""):
                                if (nameLine == ""):
                                    nameLine = content.replace("\n","")
 
                                else:
                                    # separate each nameserver using ;
                                    nameLine = nameLine + " ; " + content.replace("\n","")

# use current nameserver instead
except:
    errorMessage = tree.xpath('//div[contains(@class, "alert-danger")]')
    if (errorMessage):
        errorMessageText = errorMessage[0].text.strip()
        print(errorMessageText)

    else:
        print("Error while reading response - maybe your IP adress has been blocked (max 3 requests per day)")

    print("Get current ns server instead...")
    os.system("dig +short ns " + rootdomain + " | dnsx -silent -asn")

driver.close()

