#!/usr/bin/env python3

from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import sys
import time
import urllib.parse
import os

if (len(sys.argv) != 3):
    print("usage: {} 'companyName' depth".format(sys.argv[0]))
    print("Visit northdata.com and companies related to input company")
    sys.exit(1)

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

driver.get("https://northdata.com")
time.sleep(1)

# click allow cookies
try:
    driver.find_element(By.ID, "cmpbntyestxt").click()
except:
    pass

# enter company name in search field
textField = driver.find_element(By.CLASS_NAME, "prompt")
textField.send_keys(sys.argv[1])
textField = driver.find_element(By.CLASS_NAME, "prompt")
time.sleep(2)
textField.send_keys(Keys.ARROW_DOWN)
time.sleep(2)
textField.send_keys(Keys.RETURN)

# scroll tu bottom
actions = ActionChains(driver)
actions.send_keys(Keys.END).perform()
time.sleep(1)
actions.send_keys(Keys.ARROW_UP).perform()
time.sleep(1)

# wait for network graph
try:
    (driver.find_element(By.CLASS_NAME, "node"))
except:
    # exit if not nodes returned as result
    print("No further nodes found for: " + driver.current_url)
    print("")

nodeNames = []
nodeHref = []
nodeHrefDone = []

# get initial URL of company to start crawl
currentUrl = driver.current_url 
startNodeSplit = currentUrl.split("/")
startNodeName = startNodeSplit[3].split(",")
cleanStartNodeName = urllib.parse.unquote(startNodeName[0]).replace("+" ," ")

# url scheme: https://www.northdata.com/companyName/locationOfLaw
# some companies do not have locationOfLaw
try:
    startNodeHref = startNodeSplit[3] + "/" + startNodeSplit[4]
except:
    startNodeHref = startNodeSplit[3]

nodeNames.append(cleanStartNodeName)
nodeHref.append("/" + startNodeHref)
nodeHrefDone.append("/" + startNodeHref)

print("Query https://northdata.com/" + startNodeHref)

nodes = driver.find_elements(By.CLASS_NAME, "node")

# get all nodes that represents a company
for node in nodes:
    if (node is None):
        break

    if (node.text is None):
        print("Break node text:" + node.text)
        break

    icon = node.text[0].encode('utf-8')
    name = node.text[1:]
    href = node.get_attribute("href")

    # check if the icon is a company, otherwise skip node
    if (icon == b'\xef\x86\xad'):
        if (href not in nodeHref):
            if (href is not None):
                nodeNames.append(urllib.parse.unquote(name).replace("+", " "))
                nodeHref.append(href["animVal"])

counter = 1

# click on a company node and repeat node collection
while 1:
    allNodesDoneFlag = "1"

    for h in nodeHref:
        if (h in nodeHrefDone):
            continue
        else:
            print("Query https://northdata.com/" + h)
            counter = counter + 1

            if (counter == int(sys.argv[2])):
                sortedNames = sorted(set(nodeNames))
                print("\n\n##### Results #####\n")
                for n in sortedNames:
                    print(n)
                driver.close()
                exit(0)

            allNodesDoneFlag = "0"
            nodeHrefDone.append(h)

            try:
                driver.get("https://www.northdata.com" + h)
                time.sleep(7)
            except:
                print("Error getting " + h)

            # wait for page to load
            actions.send_keys(Keys.END).perform()
            time.sleep(1)
            actions.send_keys(Keys.ARROW_UP).perform()
            time.sleep(1)
            
            # wait for network graph
            nodes = driver.find_elements(By.CLASS_NAME, "node")

            for node in nodes:
                if (node is None):
                    break

                try:
                    icon = node.text[0].replace("\n","")
                    name = node.text[1:]
                    href = node.get_attribute("href")

                    if (icon == "\uf1ad"):
                        if (href is not None):
                            if (href["animVal"] not in nodeHref):
                                nodeNames.append(urllib.parse.unquote(name).replace("+", " "))
                                nodeHref.append(href["animVal"])
                except:
                    pass

    if (allNodesDoneFlag == "1"):
        print("\n\n##### Results #####\n")
        sortedNames = sorted(set(nodeNames))
        for n in sortedNames:
            print(n)

        driver.close()
        exit(0)

