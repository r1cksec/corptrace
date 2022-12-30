#!/usr/bin/env python3

from os import path
from selenium import webdriver                        
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.firefox.service import Service
import datetime
import html
import os
import random
import re
import string
import sys
import time

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} domainFile".format(sys.argv[0]))
    sys.exit(1)

inputDomains = sys.argv[1]
# strings that represent the imprint button
impressums = ["impressum", "imprint", "legal notice"]
# strings that could contain the company name
companyStrings = ["©", "&copy;", "GmbH", "AG", "Aktiengesellschaft", "gmbh", "Gesellschaft mit beschränkter Haftung"]
# characters that inclose the company name
borderChars = ["'", "\"", "<", ">"]
# strings that are a must have for the final result
mustContainString = ["GmbH", " AG", "Aktiengesellschaft", "gmbh", "Gesellschaft mit beschränkter Haftung"]
# strings that should not be part of the final resul
shouldNotContain = ["http://", "https://"]
# strings that will be removed from final result
replaceStrings = ["Alle Rechte vorbehalten", "All rights reserved", "Copyright"]

allDomains = []

options = FirefoxOptions()
options.add_argument("--ignore-ssl-errors=yes")
options.add_argument('--ignore-certificate-errors')
options.set_preference("network.http.redirection-limit", 4)
options.add_argument("--headless")
service = Service(log_path=path.devnull)
driver = webdriver.Firefox(options=options, service=service)
driver.set_page_load_timeout(6)

with open(inputDomains) as fp:
    # save all domains in array
    for domain in fp:
        domain = domain.replace("\n","")
        allDomains.append(domain)

    for domain in allDomains:
        impressumFound = "0" 

        # remove unwanted strings if input is incorrectly formatted
        domain = domain.replace("https://","")
        domain = domain.replace("http://","")

        if ("/" in domain):
            splittedDomain = domain.split("/")
            domain = splittedDomain[0]

        try:
            driver.get("https://" + domain)

            time.sleep(1)
            actions = ActionChains(driver)
            actions.send_keys(Keys.END).perform()

            # get impressum url
            elems = driver.find_elements(By.XPATH, "//a[@href]")
            
            href = ""
            for elem in elems:
                href = elem.get_attribute("href")
                innerHtml = elem.get_attribute("innerHTML")
                
                for imp in impressums:
                    if (imp in innerHtml.lower()):
                        impressumFound = "1"

                    if (impressumFound == "1"):    
                        break

            if (impressumFound == "1"):
                # extract company name from impressum
                driver.get(href)
                time.sleep(1)
                actions = ActionChains(driver)
                actions.send_keys(Keys.END).perform()

                websiteObject = driver.find_elements(By.XPATH, "//*")
                sourceCode = websiteObject[0].get_attribute("innerHTML")
                # generate random string for temporary files
                letters = string.ascii_lowercase
                randStr = ""
                
                for l in range(16):
                    randStr = randStr + random.choice(letters)

                createDate = datetime.datetime.today().strftime("%d-%m-%Y_%H:%M:%S")
                tempFile = "/tmp/get-page-owner-" + createDate + "-" + randStr 

                filePointer = open(tempFile, "w")
                filePointer.write(html.unescape(sourceCode))
                filePointer.close()
                
                # search for strings like copyright, GmbH, AG etc
                matchFound = "0"
                resultString = ""

                for companyStr in companyStrings:
                    fp = open(tempFile, "r")

                    for line in fp:
                        line = line.replace("\n","")
                    
                        if (companyStr in line):
                            # position of first char of matching substring
                            index = line.find(companyStr)
                            stringBeforeMatch = ""

                            while 1:
                                index = index - 1
                                try:
                                    currentChar = line[index]
                                except:
                                    break

                                if (currentChar in borderChars):
                                    break

                                stringBeforeMatch = currentChar + stringBeforeMatch

                            # position of last char of matching substring
                            index = line.find(companyStr) + len(companyStr) - 1 
                            stringAfterMatch = ""

                            while 1:
                                index = index + 1
                                try:
                                    currentChar = line[index]
                                except:
                                    break

                                if (currentChar in borderChars):
                                    break

                                stringAfterMatch = stringAfterMatch + currentChar

                            resultString = stringBeforeMatch + companyStr + stringAfterMatch
                            
                            # check if result contains GmbH oder AG or similar
                            for mustString in mustContainString:
                                if (mustString in resultString):
                                    matchFound = "1"

                                    # make sure that the string is not a common false positive
                                    for bannedString in shouldNotContain:
                                        if (bannedString in resultString):
                                            matchFound = "0"

                                    if (matchFound == "1"):
                                        break

                        if (matchFound == "1"):
                            break

                    fp.close()

                    if (matchFound == "0"):
                        resultString = "Not Found"

                    if (matchFound == "1"):
                        break
                        
                resultString = resultString.replace(";","")

                # remove unwanted strings 
                # multiple whitespaces
                resultString = re.sub(' +', ' ',resultString.lstrip())
                for replaceStr in replaceStrings:
                    resultString = resultString.replace(replaceStr,"")
                    # case insensitive
                    resultString = resultString.replace(replaceStr.lower(),"")
                
                print(domain + " ; " + resultString)
                os.remove(tempFile)
            else:
                print(domain + " ; No Imprint")

        except Exception as e:
            print(domain + " ; Not Found")
            #print("Error: " + e)

driver.close()

