#!/bin/bash
file="/usr/share/seclists/Discovery/DNS/namelist.txt"
outfile="${1}-subdomain.txt"

# Variables for terminal requests.
[[ -t 2 ]] && {
    alt=$(      tput smcup  || tput ti      ) # Start alt display
    ealt=$(     tput rmcup  || tput te      ) # End   alt display
    hide=$(     tput civis  || tput vi      ) # Hide cursor
    show=$(     tput cnorm  || tput ve      ) # Show cursor
    save=$(     tput sc                     ) # Save cursor
    load=$(     tput rc                     ) # Load cursor
    bold=$(     tput bold   || tput md      ) # Start bold
    stout=$(    tput smso   || tput so      ) # Start stand-out
    estout=$(   tput rmso   || tput se      ) # End stand-out
    under=$(    tput smul   || tput us      ) # Start underline
    eunder=$(   tput rmul   || tput ue      ) # End   underline
    reset=$(    tput sgr0   || tput me      ) # Reset cursor
    blink=$(    tput blink  || tput mb      ) # Start blinking
    italic=$(   tput sitm   || tput ZH      ) # Start italic
    eitalic=$(  tput ritm   || tput ZR      ) # End   italic
[[ $TERM != *-m ]] && {
    red=$(      tput setaf 1|| tput AF 1    )
    green=$(    tput setaf 2|| tput AF 2    )
    yellow=$(   tput setaf 3|| tput AF 3    )
    blue=$(     tput setaf 4|| tput AF 4    )
    magenta=$(  tput setaf 5|| tput AF 5    )
    cyan=$(     tput setaf 6|| tput AF 6    )
}
    white=$(    tput setaf 7|| tput AF 7    )
    default=$(  tput op                     )
    eed=$(      tput ed     || tput cd      )   # Erase to end of display
    eel=$(      tput el     || tput ce      )   # Erase to end of line
    ebl=$(      tput el1    || tput cb      )   # Erase to beginning of line
    ewl=$eel$ebl                                # Erase whole line
    draw=$(     tput -S <<< '   enacs
                                smacs
                                acsc
                                rmacs' || { \
                tput eA; tput as;
                tput ac; tput ae;         } )   # Drawing characters
    back=$'\b'
} 2>/dev/null ||:

echo "${white}"
if which figlet > /dev/null; then figlet DNS Tool;else echo "DNS Tool"; fi
echo "${reset}"

if [ ! -z "$1" ] ; then
    echo "${green}[+] Domain set to ${white}$1${reset}" 
else
    echo "Usage: $0 bigcorpone.com"
    echo ""
    exit 1
fi

if [ -f $outfile ] ; then
    echo "${red}[!] $outfile already present please remove${red}"
    exit 1
fi

if [ ! -f $file ] ; then
    echo "${red}[!] missing $file${reset}"
    exit 1
fi


echo "${green}[+] Looking for name servers${reset}"
whois $1 | egrep -o 'Name.Server:.*\..*' | awk -F':' '{print $2}' | sort | uniq > ${1}-ns.txt
echo "${green}[+] Found ${white}$(cat $1-ns.txt | wc -l) ${green}name servers${reset}"

for ns in $(cat $1-ns.txt); do
    host -l $1 $ns > ${1}-zonexfer.tmp 2> /dev/null
    if [ $? -eq 1 ]; then
        echo "${red}[-] ${white}$ns${red} zone transfer failed${reset}"
    else 
        echo "${green}[+] ${white}$ns${green} zone transfer successfull${reset}"
        host -l $1 $ns > ${1}-zonexfer.txt 
        echo "${green}[+] ${white}$(cat ${1}-zonexfer.txt | grep "has address" | wc -l)${green} subdomains found with zone xfer${reset}"
        echo ""
        cat ${1}-zonexfer.txt | grep 'has address' | awk -F"has address" '{printf "%-18s %s\n",$2, $1}'
        echo ""

    fi 
done

if [ -f ${1}-zonexfer.tmp ] ; then
    rm ${1}-zonexfer.tmp 
fi

entries=$(cat $file | wc -l)
echo ""
echo "${green}[+] starting DNS brute with ${white}${entries}${green} entries${reset}"
echo ""

count=1
tput civis
for sub in $(cat $file); do
    percentage=$(printf %.2f $(echo "$count/$entries*100" | bc -l))
    subdomain="${italic}Trying: ${percentage}%  ${sub}" 
    echo -ne "${green}$subdomain${reset}"
    output=$(host ${sub}.$1 | grep 'has address') # | awk -F"has address" '{printf "%s %s",$2, $1}')
    echo -ne "\033[1K"
    for c in $(seq 0 ${#subdomain}); do
        echo -ne "\b"
    done
    if [ ! -z "$output" ] ; then
        echo $output | awk -F"has address" '{printf "%-18s %s\n",$2,$1}' | tee -a ${outfile}
    fi
    count=$((count+1)) 
done
echo ""
echo "${green}[+] Completed found ${white} $(cat ${outfile} | wc -l) domains ${reset}"
echo ""
tput cvvis
