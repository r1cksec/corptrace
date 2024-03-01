#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import sys
import time
import urllib.parse
import os

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} searchKey".format(sys.argv[0]))
    print("Run Google dork and colelct linkedin employees")
    sys.exit(1)


"""FUNCTION
Extract username from linkedIn URL

selObj = Selenium href object
"""
def extractEmplName(selObj):
    for url in urls:
        try:
            href = url.get_attribute("href")
        except Exception as e:
            print("Error while getting href: " + e)
            return
        
        if ("google." in href):
            continue
        
        if ("linkedin.com/in" in href):
            try:
                splittedHref = href.split(".linkedin.com/in/")
                cleanHref = splittedHref[1]
                cleanHref = cleanHref.replace("\n","")
                cleanHref = urllib.parse.unquote(cleanHref)
                splittedName = cleanHref.split("-")
                cleanEmplName = ""
        
                for nameChunk in splittedName:
                    if ("/" in nameChunk):
                        splNameChunk = nameChunk.split("/")
                        nameChunk = splNameChunk[0]
                    if (not any(chr.isdigit() for chr in nameChunk)):
                        cleanEmplName = cleanEmplName + " " + nameChunk
                    if (nameChunk[0] == "%"):
                        cleanEmplName = cleanEmplName + " " + nameChunk   
                allEmployees.append(cleanEmplName[1:])
        
            except Exception as e:
                print("Error: " + href + " -- " + e)


# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

allEmployees = []

searchKey = 'intitle:"' + sys.argv[1]+ '" inurl:"linkedin.com/in/" site:linkedin.com'

# search via Google
url = "https://www.google.com"
driver.get(url)
time.sleep(2)

# accept cookies
try:
    WebDriverWait(driver,5).until(EC.element_to_be_clickable((By.ID, "L2AGLb"))).click()
    time.sleep(4)
except:
    pass

# send keys to search field
try:
    textField = WebDriverWait(driver,10).until(EC.element_to_be_clickable((By.CLASS_NAME, "gLFyf")))
    textField.send_keys(searchKey)
    textField.send_keys(Keys.RETURN)
except Exception as e:         
    print(e)
    print("Error while reading response - maybe your IP adress has been blocked")
    exit(1)

time.sleep(5)

# scroll down
for i in range(10):
    actions = ActionChains(driver)
    actions.send_keys(Keys.END).perform()
    time.sleep(3)

    # press more results button
    try:
        button = driver.find_element_by_xpath("//h3[contains(@class, 'RVQdVd')]")
        button.click()
    except:
        pass

# get employee names
urls = driver.find_elements(By.XPATH, "//a[@href]")
extractEmplName(urls)

driver.close()

# print employee names
sortedEmployees = sorted(set(allEmployees))

for e in sortedEmployees:
    print(e)

