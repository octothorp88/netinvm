#!/bin/bash

website="$1"

echo "validating website $1"

if [ ! -z "$1" ] ; then
    echo [+] $1 is set
else
    echo "Usage: $0 www.website.com"
    exit 1
fi

# wget -O- www.megacorpone.com 2>/dev/null| grep -Eo "[A-Za-z0-9]+\.megacorpone\.com"  | sort | uniq
wget -O- www.megacorpone.com 2>/dev/null| grep -Eo "[^/]*\.megacorpone\.com"  | sort | uniq > ${1}-links.txt

echo "[+] $(wc -l ${1}-links.txt) uniq links found"
echo "[+] pulling ip addresses for $1 links"
echo ""
(for url in $(cat $1-links.txt); do
    host $url | awk -F" " '{printf "%-15s %-40s \n", $4,$1}'
done ) |  tee  ${1}-domainip.txt
echo ""
echo "[+] $(wc -l ${1}-domainip.txt) uniq subdomains found"
cat ${1}-domainip.txt | cut -d" " -f 1 | sort | uniq | tee ${1}-iplist.txt
echo ""

echo "[+] Looking for email addresses"
echo ""

wget -O- ${1}/about.html 2>/dev/null   | grep -Eo "[a-zA-Z]+@.[a-zA-Z0-9\-_]+\.[a-zA-Z0-9]+" | sort | uniq  | tee ${1}-email.txt

echo ""
echo "[+] $(wc -l ${1}-email.txt) uniq emails found"




