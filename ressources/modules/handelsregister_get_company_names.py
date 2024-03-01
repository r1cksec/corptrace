#!/usr/bin/env python3

from lxml import etree
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import sys
import time
import os

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} companyName".format(sys.argv[0]))
    print("Visit handelsregister.de and extract company names")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

url = "https://www.handelsregister.de"
driver.get(url)

# get current language settings
greetingsElement = driver.find_elements(By.ID, "zeile1")
greetings = greetingsElement[0].get_attribute("innerHTML")

if ("Common register portal" in greetings):
   searchButton = "Advanced search"
   pressSearch = "Find"
elif ("Gemeinsames Registerportal" in greetings):
   searchButton = "Erweiterte Suche"
   pressSearch = "Suchen"
else:
    print("Sorry only support for englisch or german, switch your default language settings for gecko")
    searchButton = ""
    exit(1)

# click on Advanced Search
advSearch = driver.find_elements(By.XPATH, "//*[contains(text(), '" + searchButton + "')]")
advSearch[1].click()
time.sleep(3)

# enter search key
textField = driver.find_element(By.ID, "form:schlagwoerter")
textField.send_keys(sys.argv[1])
time.sleep(2)

# choose 100 results from dropdown
dropDown = driver.find_element(By.XPATH, "//div[@id='form:ergebnisseProSeite']")
dropDown.click()
time.sleep(2)
driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
time.sleep(2)
insideDropdown = driver.find_element(By.ID, "form:ergebnisseProSeite_3")
insideDropdown.click()

# click on search
obj = driver.find_elements(By.XPATH, "//*[contains(text(), '" + pressSearch + "')]")
obj[0].click()

time.sleep(15)

# parse results
sourceCode = driver.page_source
tree = etree.HTML(sourceCode)

tbody = tree.xpath('//*[@id="ergebnissForm:selectedSuchErgebnisFormTable_data"]')[0]
allTrsClasses = ["ui-widget-content ui-datatable-even", "ui-widget-content ui-datatable-odd"]

for trClass in allTrsClasses:
    allEvenTrs = tbody.xpath('.//tr[@class="' + trClass + '"]')

    for tr in allEvenTrs:
        # print name of company, location and history
        results = tr.xpath('.//span[contains(@class, "marginLeft20") or contains(@class, "verticalText") or contains(@class, "marginLeft20 fontSize85")]')

        for i in results:
            # skip status
            if (i.text == "aktuell" or i.text == "currently registered"):
                continue

            print(i.text, end="; ")

        print("")

driver.close()

