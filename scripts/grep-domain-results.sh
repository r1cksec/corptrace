pathToResults="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Please enter path to result directory:"
read pathToResults

# grep subdomain results
cat ${pathToResults}/amass-osint/* | grep -v Querying >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/amass-reverse-lookup-ranges/* | cut -d " " -f 1 >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/cert-san-finder-range/* | grep -v "Final Domain" | grep -v nmap | sort -u >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/hakrawler/* | awk -F "http" '{print $2}' | cut -d "/" -f 3 | sort -u >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/subfinder/* | grep -v "INF" | grep -v "WRN" | sort -u >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/waybackurls/* | sort -u >> ${pathToResults}/all-domains.txt
cat ${pathToResults}/cert-san-finder-range/* | grep -v "Final Domain" | grep -v nmap | sort -u >> ${pathToResults}/all-domains.txt

