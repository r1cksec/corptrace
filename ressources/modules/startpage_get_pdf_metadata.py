#!/usr/bin/env python3

from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import datetime
import sys
import time
import os

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} domain".format(sys.argv[0]))
    print("Run Google dork on startpage.com and browse 3 first pages, wget all pdf files and run exiftool")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

searchKey = 'inurl:"' + sys.argv[1] + '" filetype:pdf'

# search via startpage
url = "https://startpage.com"
driver.get(url)
time.sleep(2)

# send keystrokes of searchkey
textField = WebDriverWait(driver,10).until(EC.element_to_be_clickable((By.ID, "q")))
textField.send_keys(searchKey)
textField.send_keys(Keys.RETURN)

urls = []

# scroll to end
time.sleep(5)
actions = ActionChains(driver)
actions.send_keys(Keys.END).perform()

# check if the url contains .pdf 
pdfLinks = driver.find_elements(By.XPATH, "//a[@href]")

for pL in pdfLinks:
    pdfUrl = pL.get_attribute("href")

    if (".pdf" in pdfUrl):
        urls.append(pdfUrl)

# search 3 first pages
for i in range(1,3):
    # click Next
    try:
        nextButton = driver.find_elements(By.XPATH, './/button[@class = "pagination__next-prev-button next"]')
        for button in nextButton:
            button.click()
    except Exception as e:
        print("Error getting Next Page Number -- " + str(e))

    # scroll to end
    time.sleep(5)
    actions = ActionChains(driver)
    actions.send_keys(Keys.END).perform()
    
    # check if url contains .pdf
    pdfLinks = driver.find_elements(By.XPATH, "//a[@href]")
    
    for pL in pdfLinks:
        urlToPdf = pL.get_attribute("href")
        urlExtension = urlToPdf[-4:]

        if (".pdf" in urlExtension):
            urls.append(urlToPdf)

driver.close()

timestamp = datetime.datetime.today().strftime("%d-%m-%Y_%H:%M:%S")
tempDir = "/tmp/get-pdf-meta-" + timestamp
os.makedirs(tempDir)

counter = 0

# download pdf files
uniqUrls = sorted(set(urls))

counter = 0
print("Results:")

for u in uniqUrls:
    splittedUrl = u.split("/")
    os.system("wget --quiet \"" + u + "\" -O \"" + tempDir + "/" + str(counter) + ".pdf\"")
    counter = counter + 1

os.system("cd " + tempDir + "; exiftool * | grep -i \"Producer\|Author\|Creator\|Email\" | sort -u")

# remove directory
os.system("rm -rf " + tempDir)

print("\nDocuments:")
for x in uniqUrls:
    print(x)

