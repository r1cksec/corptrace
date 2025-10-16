#!/usr/bin/env python3

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json
import requests
import sys
import os
import time

# check amount of passed arguments
if not (len(sys.argv) == 4 or len(sys.argv) == 5):
    print("usage: {} domain email password [forceDetailCollection]".format(sys.argv[0]))
    print("Visit xing.com and extract all empoylees")
    sys.exit(1)

# used to force detail collection (send api request for each employee)
forceDetails = "false"

# check for optional forceDetailCollection flag
if (len(sys.argv) == 5):
    forceDetails = "true"

# get absolute path to current directory
currentPosition =  os.path.realpath(__file__)
dn = os.path.dirname(currentPosition)

# initiate gecko webdriver
with open(dn + "/initiate_webdriver", "rb") as sourceFile:
    code = sourceFile.read()
exec(code)

# browse to xing
domain = sys.argv[1]
email = sys.argv[2]
password = sys.argv[3]
url = "https://login.xing.com"
driver.get(url)

wait = WebDriverWait(driver, 11)

# click allow cookies
try:
    driver.find_element(By.CSS_SELECTOR, ".sc-dcJsrY.eLOIWU").click()
except:
    pass

wait = WebDriverWait(driver, 5)

# login
WebDriverWait(driver,10).until(EC.element_to_be_clickable((By.ID, "username")))
userForm = driver.find_element(By.ID, "username")
userForm.send_keys(email)
time.sleep(1)

pwForm = driver.find_element(By.ID, "password")
pwForm.send_keys(password)
time.sleep(1)
pwForm.send_keys(Keys.RETURN)

# wait for login to complete
time.sleep(5)

# click skip if prompted for MFA
try:
    driver.find_element(By.CLASS_NAME, "button-styles__Text-sc-1602633f-5").click()
except:
    pass

time.sleep(1)

# search for company name
searchUrl = "https://www.xing.com/search/companies?sc_o=navigation_search_companies_search&sc_o_PropActionOrigin=navigation_badge_no_badge&keywords=" + domain
driver.get(searchUrl)
try:
    companyProfile = driver.find_element(By.CSS_SELECTOR, '[data-testid="company-card-link-test-id"]')
    companyHref = companyProfile.get_attribute("href")
    companyPage = companyHref.replace("https://www.xing.com/pages/", "")
except Exception as e:
    print(e)
    print("Error while searching for company profile using " + domain + " - maybe this is not a widely used domain")
    driver.get("https://www.xing.com/login/logout?sc_o=navigation_logout&sc_o_PropActionOrigin=navigation_badge_no_badge")
    time.sleep(3)
    driver.close()
    exit(1)

# extract cookie
cookies = driver.get_cookies()
for c in cookies:
    if ("login" == c["name"]):
         loginCookie = {"login": c["value"]}

time.sleep(2)

# get company ID
xingApi = "https://www.xing.com/xing-one/api"
headers = {"Content-Type": "application/json"}
body = {"operationName":"EntitySubpage", "variables":{"id":companyPage, "moduleType":"employees"},
        "query":"query EntitySubpage($id: SlugOrID!) {entityPageEX(id: $id) { ... on EntityPage {context { companyId }}}}"}

responseId = requests.post(xingApi, headers=headers, json=body)
jsonId = responseId.json()
companyId = jsonId["data"]["entityPageEX"]["context"]["companyId"]

# get employees
body2 = {"operationName":"Employees", "variables":{"consumer":"", "id":companyId, "first":2999,
         "query":{"consumer":"web.entity_pages.employees_subpage","sort":"CONNECTION_DEGREE"}},
         "query":"query Employees($id: SlugOrID!, $first: Int, $after: String, $query: CompanyEmployeesQueryInput!, $consumer: String! = \"\", $includeTotalQuery: Boolean = false) { company(id: $id) { id totalEmployees: employees(first: 0, query: {consumer: $consumer}) @include(if: $includeTotalQuery) { total } employees(first: $first, after: $after, query: $query) { total edges { node { profileDetails { id firstName lastName displayName gender pageName location {city street} occupations { subline }}}}}}}"}

empoyleesResponse = requests.post(xingApi, headers=headers, json=body2, cookies=loginCookie)
employeesJson = empoyleesResponse.json()
empoyleeObjects = employeesJson["data"]["company"]["employees"]["edges"]

print("Firstnam ; Lastname ; Occupation ; Location ; Email ; Phone ; Mobile ; Gender ; Url")

for obj in empoyleeObjects:
    # placeholder for detail contact information
    email = ""
    phone = ""
    mobile = ""
    city = ""
    street = ""

    # collect contact details for each employee
    employee = obj["node"]["profileDetails"]
    print(employee["firstName"].lower(), end=" ; ")
    print(employee["lastName"].lower(), end=" ; ")
    try:
        print(employee["occupations"][0]['subline'], end=" ; ")
    except:
        print("Unknown", end=" ; ")

    # users who enter a street name may provide additional information
    if (employee["location"] is not None) or (forceDetails == "true"):
        if (employee["location"]["city"] is not None) or (forceDetails == "true"):
            city = employee["location"]["city"]

        if (employee["location"]["street"] is not None) or (forceDetails == "true"):
            body3 = {"operationName":"profileContactDetails", "variables":{"profileId":employee['pageName']},
                     "query":"query profileContactDetails($profileId: SlugOrID!) { profileModules(id: $profileId) { xingIdModule { ...xingIdContactDetails outdated lastModified } }}fragment xingIdContactDetails on XingIdModule { contactDetails { business { address { city country { countryCode name: localizationValue } province { id canonicalName name: localizationValue } street zip } email fax { phoneNumber } mobile { phoneNumber } phone { phoneNumber }}}}"}
            contactResponse = requests.post(xingApi, headers=headers, json=body3, cookies=loginCookie)
            contactJson = contactResponse.json()

            # sleep do prevent rate limit (requesting details for each employee)
            if (forceDetails == "true"):
                time.sleep(15)

            contact = contactJson["data"]["profileModules"]["xingIdModule"]["contactDetails"]["business"]
            if (contact["email"] is not None):
                email = contact["email"]

            if (contact["phone"] is not None):
                if (contact["phone"]["phoneNumber"] is not None):
                    phone = contact["phone"]["phoneNumber"]

                if (contact["mobile"] is not None and contact["mobile"]["phoneNumber"] is not None):
                    mobile = contact["mobile"]["phoneNumber"]

            if (employee["location"]["street"] is not None):
                street = employee["location"]["street"]

    print(city + ", " + street, end=" ; ")
    print(email, end=" ; ")
    print(phone, end=" ; ")
    print(mobile, end=" ; ")
    print(employee["gender"], end=" ; ")
    profilePage = "https://www.xing.com/profile/" + employee["pageName"]
    print(profilePage)

time.sleep(1)
driver.get("https://www.xing.com/login/logout?sc_o=navigation_logout&sc_o_PropActionOrigin=navigation_badge_no_badge")
time.sleep(3)
driver.close()

