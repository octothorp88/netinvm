# First we need to identify the hosts that are online
# The easiest thing is to find the systems that respond
# to ICMP

if [ ! -x "$(command -v nmap)" ];then
        echo "[+] nmap not detected...Installing"
        sudo apt-get install nmap -y >> install.log
fi

if [ ! -x "$(command -v cutycapt)" ];then
        echo "[+] cutycapt not detected...Installing"
        sudo apt-get install cutycapt -y >> install.log
fi

if [ ! -x "$(command -v jq)" ];then
        echo "[+] jq not detected...Installing"
        sudo apt-get install jq -y >> install.log
fi

if [ "$1" != "" ]; then
    echo "Parameter 1 is set to $1"
else
    echo "Usage: $0 10.10.1.1-254"
    exit
fi

if [ ! -d "$1/enum" ]; then
    echo "making directory $1/enum"
    mkdir -p $1/{enum,cutycapt}
fi

echo "[+] Running simple Ping sweep against $1"
nmap -sP $1 -oA $1/PingSweep >/dev/null
cat $1/pingsweep.gnmap  | grep Host | cut -d" " -f 2 > $1/hosts.txt
echo "[i] Found $(wc -l $1/hosts.txt | cut -d" " -f 1) hosts"

echo "[+] NMAP scans on all hosts"
for host in $(cat $1/hosts.txt); do
    [[ -d  $1/$host ]] || mkdir $1/$host
    echo "[+] running nmap top 1K on $host"
    nmap --top-ports 1000 -sV $host -oA $1/$host/${host}-top1k &> /dev/null
    echo "[+] nmap top 1k scan complete on host $host"
    if grep -q "445/tcp" $1/$host/${host}-top1k.nmap; then
        echo [+] SAMBA/SMB detected
        echo [+] Running nmap smb-enum scripts
        nmap $host -p 445 --script=smb-enum-shares.nse,smb-enum-users.nse -oA $1/$host/${host}-smb &>/dev/null
        echo "    smbget -R smb://<ip>/anonymous"
        echo [+] Running nmap smb-vuln scripts
        nmap $host -p 445 --script=smb-vuln* -oA $1/$host/${host}-smbvulns &>/dev/null
    fi

    if grep -Eoq '^[0-9]+/.*http' $1/$host/${host}-top1k.nmap; then
        for port in $(grep -Eo '^[0-9]+/.*http' $1/$host/${host}-top1k.nmap | cut -d"/" -f1);
        do
            echo -ne "\r     - http found $host $port\r";sleep 2; cutycapt --url=http://$host:$port --out=$1/cutycapt/$host-$port.png>/dev/null
            echo -ne "\r     - nmap http-title $host $port\r";sleep 2; nmap -p $port --script http-title $host -oA $1/$host/$host-$port-HTTP-TITLE
            echo -ne "\r     - Gobuster that mofo $host:$port\r";sleep2; gobuster dir -u http://${host}:${port} -w /usr/share/wordlists/dirb/big.txt -q -x "php,txt,html,bak,old" -o $1/$host/$host-$port-gobuster.txt
        done
        echo "[+] Identified $(grep -Eo '^[0-9]+/.*http' $1/$host/${host}-top1k.nmap | wc -l) web servers on ${host}"
    fi



done

if ls ${1}/cutycapt/*.png &> /dev/null;
then
    echo "[+] Creating Viewable HTML page"
    cat <<- EOF > $1/cutycapt.html
    <!DOCTYPE html>
    <html>
        <head>
        </head>
        <body>
EOF
        for img in $(ls -1 $1/cutycapt/*.png)
            do 
                echo "<h2>$(basename $img)</h2>"
                echo "<a href=\"http://${host}:${port}\">"
                echo "<img src=\"cutycapt/$(basename $img)\">"
                echo "</a>"

        done >> $1/cutycapt.html

        cat <<- EOF >> $1/cutycapt.html
        </body>
        </html>
EOF
else
    echo "[+] No webpages detected on standard ports"
fi
echo "complete"


