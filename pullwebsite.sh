#!/bin/bash

website="$1"

echo "validating website $1"

if [ ! -z "$1" ] ; then
    echo [+] $1 is set
else
    echo "Usage: $0 www.website.com"
    exit 1
fi

base=$(echo $1 | cut -d"." -f2)
echo "[+] Base name is $base"

wget -O- $1 2>/dev/null | grep -Eo "href=\"//.*/" | grep -Eo "[^0-9/\_\\][a-zA-Z0-9]+\.[^0-9][a-zA-Z]+\.[^0-9][A-Za-z]+" | grep $base | sort | uniq > ${1}-links.txt

echo "[+] $(wc -l ${1}-links.txt) uniq links found"
echo "[+] pulling ip addresses for $1 links"
echo ""
(for url in $(cat $1-links.txt); do
    # host $url | awk -F" " '{printf "%-15s %-40s \n", $4,$1}'
    output=$(host $url | grep "has address")
    if [ $? -eq 0 ]; then 
        echo $output | awk -F" has address " '{printf "%-15s %-40s \n", $2,$1}'
    fi
done ) |  tee  ${1}-domainip.txt
echo ""
echo "[+] $(wc -l ${1}-domainip.txt) uniq subdomains found"
cat ${1}-domainip.txt | cut -d" " -f 1 | sort | uniq | tee ${1}-iplist.txt
echo ""

echo "[+] Looking for email addresses"
echo ""

# wget -O- ${1}/about.html 2>/dev/null   | grep -Eo "[a-zA-Z]+@.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9]+" | sort | uniq  | tee ${1}-email.txt

echo ""
echo "[+] $(wc -l ${1}-email.txt) uniq emails found"




