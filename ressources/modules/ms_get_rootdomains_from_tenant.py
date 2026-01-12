#!/usr/bin/env python3

from urllib.request import urlopen, Request
import json
import sys

# check amount of passed arguments
if (len(sys.argv) != 2):
    print("usage: {} domain ".format(sys.argv[0]))
    sys.exit(1)

domain = sys.argv[1]

try:
    req = Request("https://login.microsoftonline.com/" + domain + "/v2.0/.well-known/openid-configuration")
    with urlopen(req, timeout=20) as resp:
        data = resp.read()
        tenantData = json.loads(data.decode("utf-8"))

    tenantUrl = tenantData["token_endpoint"]
    splitTenant = tenantUrl.split("/")
    tenantId = splitTenant[3]

except Exception as e:
    print("Error while getting tenant id:")
    print(e)
    exit(1)

url = "https://accounts.accesscontrol.windows.net/" + tenantId + "/metadata/json/1"

try:
    req = Request(url, headers={"User-Agent": "python-urllib/3"})
    with urlopen(req, timeout=20) as resp:
        data = resp.read()
        metadata = json.loads(data.decode("utf-8"))

    allDomains = []

    for audience in metadata["allowedAudiences"]:
        domain = audience.split("accounts.accesscontrol.windows.net@")
        domainParts = domain[1].strip(".").lower().split(".")

        # skip non domains
        if (len(domainParts) < 2):
            continue

        # get rootdomain from subdomain
        elif (len(domainParts) > 2):
            allDomains.append(".".join(domainParts[-2:]))

        # add rootomain
        elif (len(domainParts) == 2):
            allDomains.append(".".join(domainParts))

    uniqRootdomains = sorted(set(allDomains))

    for ud in uniqRootdomains:
        if (not ud == "onmicrosoft.com"):
            print(ud)

except Exception as e:
    print("Error while getting rootdomains:")
    print(e)
    exit(1)

