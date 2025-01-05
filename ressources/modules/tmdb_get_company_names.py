#!/usr/bin/env python3

from selenium.webdriver.common.by import By
import sys
import os

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} 'companyName'".format(sys.argv[0]))
    print("Visit tmdb.eu and extract brand names")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

companyName = sys.argv[1]
baseUrl = "https://tmdb.eu/suche/marken.html?s=" + companyName + "&in=trademark&db%5B%5D=dpma&db%5B%5D=euipo&db%5B%5D=wipo&db%5B%5D=swiss&db%5B%5D=uspto&match=is&classes=&page="
print("ID ; Brand ; Class ; Owner ; Filling ; Registration ; End of Protection ; Status")

allBrands = []

for counter in range(1, 9):
    currentUrl = baseUrl + str(counter)
    driver.get(currentUrl)

    # get table cells
    tableRows = driver.find_elements(By.XPATH, '//div[@class="tm-results-entry"]')
    
    for row in tableRows:
        line = row.text.replace(";","")
        line = line.replace("\n"," ; ")

        if (line not in allBrands):
            print(line)
            allBrands.append(line)
        
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")

    currentPage = driver.current_url
    pageNumber = currentPage[-1:]

    # exit after last page
    if (int(pageNumber) != counter):
        driver.close()
        exit(0)

