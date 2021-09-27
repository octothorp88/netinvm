#!/bin/sh
ftp=0

while [ "$1" != "" ]; do
    case $1 in
        --ftp )     shift
                    ftp=1
                    ;;
    esac
done
red='\e[1;31m'
grn='\e[1;32m'
yel='\e[1;33m'
blu='\e[1;34m'
mag='\e[1;35m'
cyn='\e[1;36m'
wht='\e[1;97m'
gry='\e[1;37m'
lgrn='\e[1;92m'
end='\e[0m'

if  ! dpkg-query -l figlet > /dev/null; then
    echo $grn[+]$end Installing figlet
    echo
    sudo apt-get -y install figlet
    echo $grn
    figlet Figlet!
    echo $end
    echo
fi

# sudo locale-gen "en_US.UTF-8"

install_apt_pkg() {

#    if  ! dpkg-query -l ${1} > /dev/null; then
    if [ $(dpkg-query -W -f='${Status}' ${1} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
            echo $grn[+]$end Installing ${1} ${2}
            echo $grn
            figlet ${1}
            echo $end
            echo
            sudo apt-get -y install ${1}
            echo
            echo $grn[+]$end COMPLETE apt install ${3}
            echo $grn --------------------------------------------------------- $end
        else
            echo $yel[*]$end ${1} previously installed
        fi
    }

pull_git_repo() {
    if [ $# -ne 3 ]; then
        echo $red [!] ERROR pulling git REPO not enough ARGS$end
        return
    fi
    if [ ! -d ${2} ] ; then
            echo $grn[+]$end git pull ${3} repo to ${2}
            echo $grn
            figlet ${3}
            echo $end
            echo 
            sudo git clone ${1} ${2}
	    echo 
            echo $grn[+]$end COMPLETE ${3} GIT PULL
            echo $grn --------------------------------------------------------- $end
            echo
        else
            echo $yel[*]$end ${3} previously pulled from git
        fi
}

create_symlink() {
    if [ ! -L ${2} ]; then
        echo $grn[+]$end linking $(basename -- $2)
            if [ -f ${2} ]; then mv ${2} ${2}_orig ; fi
        ln -s ${1} ${2}
    else
        echo $yel[*]$end $(basename -- $2) previously linked
    fi
}
# ASCII art by http://patorjk.com/software/taag/#p=display&f=Graffiti&t=kali%0A
# can be added with figlet and the Graffiti font

sudo -l >/dev/null
echo $grn
cat << "EOF"
 _______          __  .___     ____   _________
 \      \   _____/  |_|   | ___\   \ /   /     \
 /   |   \_/ __ \   __\   |/    \   Y   /  \ /  \
/    |    \  ___/|  | |   |   |  \     /    Y    \
\____|__  /\___  >__| |___|___|  /\___/\____|__  /
        \/     \/              \/              \/
  ___________________________________ _____________
 /   _____/\_   _____/\__    ___/    |   \______   \
 \_____  \  |    __)_   |    |  |    |   /|     ___/
 /        \ |        \  |    |  |    |  / |    |
/_______  //_______  /  |____|  |______/  |____|
        \/         \/
EOF
echo $end

if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ] ; then
    echo $grn
        figlet VStudio Code
    echo $end
    echo $yel[+]$end Adding Microsoft GPG key and Apt Sources
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/microsoft.gpg
    sudo mv /tmp/microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo bash -c 'cat << EOF > /etc/apt/sources.list.d/vscode.list
deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main
EOF'
else
    echo $yel[*]$end Microsoft APT repo previously configured
fi

todaysdate=`date +%m%d`
aptdate=`date -r /var/lib/apt/periodic/ +%m%d`

if [ $todaysdate -eq $aptdate ] ; then
    echo $yel'[+] apt-get update already ran today' $end
else
    echo $grn'[*] Running apt-get update to get things up to date' $end
    sudo apt-get update -y
fi

install_apt_pkg figlet "ASCII banner thingie"

host=`hostname`
if [ "$host" = "base" ]; then
    figlet Base
elif [ "$host" = "exta" ]; then
    figlet extra
elif [ "$host" = "inta" ]; then
    figlet inta
elif [ "$host" = "dmza" ]; then
    figlet dmza
elif [ "$host" = "dmzb" ]; then
    figlet dmzb
cat <<- EOF
    Make sure you update the sudoers file for me
    user1   ALL=(ALL:ALL) ALL
EOF
    if ! dpkg-query -l git ; then
        sudo apt-get install git -y
    fi

    if ! dpkg-query -l mysql-client ; then
        sudo apt-get install mysql-client mysql-server \
            php php-gd php-mysqli libapache2-mod-php -y
    fi

    if [ ! -d /var/www/html/dvwa ] ; then
        sudo git clone --recursive https://github.com/ethicalhack3r/DVWA.git /var/www/html/dvwa
    fi

fi

# echo $wht '[*] Check to see if Metasploit is installed' $end
if [ "$host" = "base" ] || [ "$host" = "exta" ]; then
    if ! which msfconsole > /dev/null; then
        echo $yel'[ ] metasploit not installed yet' $end
        echo [+] Downloading Metasploit
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
        chmod 755 msfinstall && \
        echo [+] Installing Metasploit
        ./msfinstall
    else
        echo $grn'[+] Metasploit is installed' $end
    fi

    # echo $wht '[*] Check if Tmux is installed' $end
    if ! which tmux > /dev/null; then
        echo [ ] tmux not installed
        echo [+] installing tmux
        sudo apt-get install tmux -y
    else
        echo $grn '[+] Tmux is already installed' $end
    fi

    # echo $wht '[*] Check if postgresql is installed' $end
    # if ! which postgresql > /dev/null; then
    if ! dpkg-query -l postgresql-common ; then
        echo [ ] postgresql not installed
        echo [+] installing postgresql
        sudo apt-get install postgresql -y
    else
        echo $grn '[+] postgresql is already installed' $end
    fi

#    if ! [ -d ~/.vim/bundle/vundle ]; then
#        echo [ ] vundle not installed
#        echo [+] installing vundle so you dont get errors in vim
#        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
#    fi
pull_git_repo https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle "Vundle package manager for VIM"

# IF this is Kali then lets get it configured correctly
elif [ "$host" = "kali" ]; then
echo $red
    figlet Kali
echo $end
    if [ ! -d /etc/ssh/default_keys ]; then
        echo $grn[+]$end Backing up origional SSH keys
        echo $grn[+]$end Default SSH keys are in /etc/ssh/default_keys
        cd /etc/ssh
        sudo mkdir default_keys
        sudo mv ssh_host* default_keys
        echo $grn[+]$end Reconfigure SSH
    echo $wht '-------------------------------------------------------------' $end
        sudo dpkg-reconfigure openssh-server
    echo $wht '-------------------------------------------------------------' $end
        # sudo md5sum ssh_host*
        # sudo md5sum default_keys/ssh_host*
    else
        echo $grn[+]$end SSH Keys previously backed up
        # cd /etc/ssh
        # (md5sum ssh_host*
        # md5sum default_keys/ssh_host*) | sort
        # echo $wht '-----------Default Keys Should Be Different----------' $end
    fi

    echo $wht '-------------------------------------------------------------' $end
    for FILE in $(cd /etc/ssh/ && ls ssh_host*)
    do
        if [ -f /etc/ssh/default_keys/${FILE} ]; then
            HASHDEFAULT=`sudo md5sum /etc/ssh/default_keys/${FILE} | awk '{print $1}'`
            HASHNEW=`sudo md5sum /etc/ssh/${FILE} | awk '{print $1}'`
            if [ ! "$HASHDEFAULT" = "$HASHNEW" ]; then
                echo $grn[+]$end $HASHNEW $FILE
            else
                echo $red[-] $HASHNEW  $FILE DEFAULT KEY$end
            fi
        fi
    done

    echo $wht '-------------------------------------------------------------' $end
    cd

echo $yel
    figlet Tool Install
echo $end

if [ ! -d ~/bin ]; then 
	mkdir ~/bin
fi

# MSFvenom Payload Creator (MSFPC) 
pull_git_repo https://github.com/g0tmi1k/msfpc /opt/msfpc "MSVenom Payload Creator"
sudo chmod +x /opt/msfpc/msfpc.sh
create_symlink /opt/msfpc/msfpc.sh ~/bin/msfpc

    pull_git_repo https://github.com/thaddeuspearson/Supersploit.git /opt/supersploit "SupersSloit"
    pull_git_repo https://github.com/danielmiessler/SecLists.git /usr/share/seclists "Seclists"
    if [ ! -L /opt/seclists ] ; then
        sudo ln -s /usr/share/seclists /opt/seclists ; echo $grn[+]$end linking $grn /opt/seclists $end
    fi
    pull_git_repo https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git /opt/windows_exploit_suggester "Windows Exploit Suggester"
    pull_git_repo https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git /opt/winpeas "WinPEAS"
    pull_git_repo https://github.com/rebootuser/LinEnum /opt/linenum "LinEnum"
    pull_git_repo https://github.com/diego-treitos/linux-smart-enumeration /opt/lse "Linux Smart Enumeration"

    pull_git_repo https://github.com/rlaw125/payloadgenerator.git /opt/payloadgenerator "PlayloadGenerator aka PGen"
    pull_git_repo https://github.com/jivoi/pentest.git /opt/pentest "jivoi pentest"
    pull_git_repo https://github.com/portcullislabs/udp-proto-scanner /opt/udp-proto-scanner "udp proto scanner"
    pull_git_repo https://github.com/Bashfuscator/Bashfuscator /opt/bashfuscator "Bashfuscator"

    pull_git_repo https://www.github.com/octothorp88/dotfiles ~/dotfiles "dotfiles"
    pull_git_repo https://github.com/commonexploits/livehosts /opt/livehosts "livehosts script"
    pull_git_repo https://github.com/commonexploits/port-scan-automation /opt/port-scan-automation "port scan automation"
    pull_git_repo https://github.com/rezasp/joomscan.git /opt/joomscan "Joomla Web CMS Scanner"
    pull_git_repo https://github.com/pythonmaster41/Go-For-OSCP.git /opt/go-for-oscp "OSCP Git info"
    pull_git_repo https://www.github.com/nccgroup/shocker /opt/shocker "Shocker NCC Group"
    pull_git_repo https://github.com/Paradoxis/StegCracker.git /opt/stegcracker "Stegcracker"
    pull_git_repo https://github.com/SecureAuthCorp/impacket.git /opt/impacket "Impacket"
    pull_git_repo https://github.com/dievus/threader3000.git /opt/threader3000 "threader3000"
    pull_git_repo https://github.com/pentestmonkey/windows-privesc-check /opt/windows-privesc-check "Windows Privesc Check"
    pull_git_repo https://github.com/pentestmonkey/unix-privesc-check /opt/unix-privesc-check "unix Privesc Check"
    # pull_git_repo https://github.com/BC-SECURITY/Empire/ /opt/psempire "Powershell Empire"
    # pull_git_repo https://github.com/PowerShellEmpire/Empire.git /opt/empire "Powershell Empire"
    pull_git_repo https://github.com/0x00-0x00/ShellPop.git /opt/shellpop "shellpop"
    pull_git_repo https://github.com/DominicBreuker/pspy.git /opt/pspy "pspy"
    pull_git_repo https://github.com/internetwache/GitTools.git /opt/GitTools "GitTools"

    if [ ! -d /opt/pspy/bin ]; then 
        echo $grn[+]$end Creating /opt/pspy
        sudo mkdir /opt/pspy/bin
        sudo chown kali: /opt/pspy/bin
        for file in pspy32 pspy32s pspy64 pspy64s; do 
            if [ ! -f /opt/pspy/${file} ]; then
                cd /opt/pspy/bin
                echo $grn[+]$end Downloading $file
                wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/${file}
            else
                echo $yel[+]$end /opt/pspy/${file} Exists
            fi
        done
        sudo chown root: /opt/pspy/bin
    else
        echo $yel[+]$end pspy directory exists
        cd /opt/pspy/bin
        cd
    fi

    # sudo pip3 install threader3000

    if [ ! -L "/usr/local/bin/threader3000" ] ; then
        sudo ln -s /opt/threader3000/threader3000.py /usr/local/bin/threader3000 ; echo $grn[+]$end linking $grn /opt/seclists $end
    fi

   #  cd /opt/impacket
   # python setup.py install


    if [ ! -L ~/.tmux.conf ]; then 
        echo $grn[+]$end Changing Permissions on ~/dotfiles directory
        create_symlink ~/dotfiles/.bashrc ~/.bashrc
        create_symlink ~/dotfiles/.vimrc ~/.vimrc
        create_symlink ~/dotfiles/tmux.conf ~/.tmux.conf
        create_symlink /mnt/hgfs/OSCP-SHARE ~/share
        create_symlink ~/share/controlpanel.txt ~/controlpanel.txt
        sudo chown -R $(whoami): ~/dotfiles
    else
        echo $yel[+]$end Permissions on ~/dotfiles directory look to be already set
    fi 

    # if ! sudo apt-get -qq install  asciio; then
        # echo $yel [+]$end Installing asciio package
        # apt-get install asciio
    # fi

    # install_apt_pkg asciio "asciio"
    install_apt_pkg code "MicroSoft Visual Studio Code"
    install_apt_pkg tldr "community driven man pages"
    install_apt_pkg libreoffice "Libre Office"
    install_apt_pkg imagemagick "Image utilities"
    install_apt_pkg unicornscan "Unicornscan"
    install_apt_pkg powercat "powercat"
    # install_apt_pkg mtpaint "Image utilities"
    # install_apt_pkg scrot "(Command Line Screen Shot)"
    install_apt_pkg sshfs "(ssh file system)"
    install_apt_pkg bvi  "(Binary VI)"
    install_apt_pkg mingw-w64 "mingw-w64 compiler for exploits"
    install_apt_pkg masscan "port scanner"
    install_apt_pkg gobuster "gobuster"
    install_apt_pkg pure-ftpd "for exfil of data"
    install_apt_pkg code "Microsoft Visual Studio Code"
    install_apt_pkg powershell "powershell"
    install_apt_pkg seclists "seclists"
    install_apt_pkg audacity "audacity"
    #install_apt_pkg exiftool "exiftool"
    install_apt_pkg steghide "steghide"
    install_apt_pkg fcrackzip "fcrackzip"
    install_apt_pkg libimage-exiftool-perl "exiftool"
    install_apt_pkg youtube-dl "youtube-dl"
    install_apt_pkg linux-exploit-suggester "Linux Exploit Suggester"
    install_apt_pkg powershell-empire "PowerShellEmpire"
    install_apt_pkg httrack "httrack"
    install_apt_pkg bc "bc calculator"
    install_apt_pkg sublist3r "Sublist3r"
    install_apt_pkg pandoc "Pandoc for OSCP Report"
    install_apt_pkg lynx "Lynx"
    install_apt_pkg texlive-full "texlive full for OSCP Report"
    install_apt_pkg texlive-latex-extra "additional latex extras for OSCP Report"
    install_apt_pkg p7zip "p7zip for OSCP Report"
    install_apt_pkg oscanner "oscanner for autorecon"
    install_apt_pkg smtp-user-enum "smtp-user-scanner for autorecon"
    install_apt_pkg sipvicious "sipvicious  for autorecon"
    install_apt_pkg tnscmd10g "tnscmd10g for autorecon"
    install_apt_pkg wkhtmltopdf "wkhtmltopdf for autorecon"
    install_apt_pkg python3-venv "python3-venv virutal enviornment"
    install_apt_pkg python3-pip "python3-pip "
    install_apt_pkg remmina "Remote Desktop Remmina"
    install_apt_pkg pngcheck "png forensics"
    install_apt_pkg foremost "file/image forensics"
    install_apt_pkg rlwrap   "rlwrap - awesome!"

    filetodownload="/opt/oscp_report/eisvogel/Eisvogel-1.5.0.tar.gz"
    pandoctemplate=/usr/share/pandoc/data/templates/eisvogel.latex
    if [ ! -f $filetodownload ]; then
        if which figlet > /dev/null; then figlet Eisvogel; fi
        if [ ! -d $(dirname $filetodownload) ]; then sudo mkdir -p $(dirname $filetodownload); fi
        echo $grn[*]$end Downloading Eisvogel Template for pandoc
        cd /tmp
        echo $grn[*]$end Downloading $(basename $filetodownload)
        wget https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v1.5.0/Eisvogel-1.5.0.tar.gz
        tar -zxvf $filetodownload eisvogel.tex >/dev/null
        cd
        if [ -f /tmp/$(basename $filetodownload) ]; then
            echo "$grn[*]$end Download Success"
            sudo mv /tmp/$(basename $filetodownload) $(dirname $filetodownload)
        else
            echo "$red[-]$end Download Failed"
        fi

        if [ ! -f $pandoctemplate ]; then
            echo $grn[*]$end creating $(dirname $pandoctemplate)
            if [ ! -d $(dirname $pandoctemplate) ]; then sudo mkdir -p $(dirname $pandoctemplate); fi
            cd $(dirname $pandoctemplate)
            sudo tar -zxvf $filetodownload eisvogel.tex >/dev/null
            sudo mv eisvogel.tex eisvogel.latex
            if [ -f $pandoctemplate ]; then
                echo $grn[*]$end $(basename $pandoctemplate) installed
            else
                echo $red[-]$end $(basename $pandoctemplate) install failed
            fi
        fi

    else
        echo $yel[*]$end Eisvogel Template for pandoc exists
    fi

    pull_git_repo https://github.com/noraj/OSCP-Exam-Report-Template-Markdown.git /opt/oscp_report/noraj "noraj pandoc OSCP template generator"
    pull_git_repo https://github.com/JohnHammond/oscp-notetaking.git /opt/oscp_report/scripts "John Hammond OSCP submission scripts"

    if [ ! -d ~/venv ]; then
        if which figlet > /dev/null; then figlet VENV DIRS; fi
        echo $grn[*]$end creating ~/venv for virtual python installs
        mkdir ~/venv
    else
        echo $yel[*]$end ~/venv previously created
    fi

    if [ ! -d ~/venv/autorecon-venv ]; then
        if which figlet > /dev/null; then figlet autorecon venv; fi
        python3 -m venv ~/venv/autorecon-venv
         if [ -f ~/venv/autorecon-venv/bin/activate ]; then
            . ~/venv/autorecon-venv/bin/activate
            if [ $? -eq 0 ]; then
                echo $grn[*]$end venv autorecon Success!
                echo $grn[*]$end Installing AutoRecon in ~/venv/autorecon
                python3 -m pip install git+https://github.com/Tib3rius/AutoRecon.git
                deactivate
            else
                echo $red[!]$end venv autorecon FAIL!
            fi
         fi
     else
        echo $yel[*]$end ~/venv/autorecon-venv previously created
    fi



    if [ $(dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        figlet Docker
        echo $grn[+]$end Adding Docker Key sudo apt-key add key
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

        echo $grn[+]$end Configure Docker APT Repository Debian Testing
        echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list

        echo $grn[+]$end Update APT for new repo
        sudo apt-get update

        echo $grn[+]$end Remove any remnants of Docker if was previously installed
        sudo apt-get remove docker docker-engine docker.io

        echo $grn[+]$end Install Docker
        sudo apt-get -y install docker-ce
    fi

    if [ ! -f /usr/share/wordlists/Top304Thousand-probable-v2.txt ]; then
        if which figlet > /dev/null; then figlet Top304Thousand Passwords; fi
        echo $grn[*]$end Downloading Top304Thousand Probable v2 Passwords
        cd /usr/share/wordlists
        sudo wget https://raw.githubusercontent.com/berzerk0/Probable-Wordlists/master/Real-Passwords/Top304Thousand-probable-v2.txt
        cd
    else
        echo $yel[*]$end Top304Thousand Probable v2 Passwords exists
    fi

    if [ ! -f /opt/initialrecon/initialrecon.py ]; then
        if which figlet > /dev/null; then figlet Initialrecon.py; fi
            echo $grn[*]$end Downloading INITIALRECON from github
        if [ ! -d /opt/initialrecon ]; then sudo mkdir /opt/initialrecon; fi
            cd /opt/initialrecon
            sudo wget https://gist.githubusercontent.com/curi0usJack/d7cd99411614b470911c584ec6cd42f8/raw/bb0acf5bcbce15d4d733aaa4903836e9c8d89700/initialrecon.py
        cd
    else
        echo $yel[*]$end INITIALRECON previously downloaded
    fi


    if [ ! -d /opt/pstools ]; then
        if which figlet > /dev/null; then figlet pstools; fi
        sudo mkdir /opt/pstools
        cd /opt/pstools
        sudo wget https://download.sysinternals.com/files/PSTools.zip
        if [ -f /opt/pstools/PSTools.zip ]; then
            sudo unzip PSTools.zip
        fi
        cd
    fi

    if [ ! -d /opt/oui ]; then
        echo $grn[*]$end Downloading Organizational Unique IDs from IEEE
        sudo mkdir /opt/oui
        cd /opt/oui
        if which figlet > /dev/null; then figlet IEEE oui.txt; fi
        sudo wget http://standards-oui.ieee.org/oui/oui.txt
        cd
        if [ ! -f /opt/oui/oui.txt ]; then
            echo $grn[*]$end Success OUI Exists in /opt
        fi
    else
        echo $yel[*]$end Organizational Unique IDs from IEEE in /opt
    fi

    if [ ! -f ~/bin/maclookup.sh ] ; then
        if which figlet > /dev/null; then figlet maclookup.sh; fi
echo $grn[+]$end creating maclookup script
cat << "EOF" > ~/bin/maclookup.sh
#!/bin/sh

MAC="$(echo $1 | sed 's/ //g' | sed 's/-//g' | sed 's/://g' | cut -c1-6)";
ORIGMAC="$(echo $1 | cut -c1-8)";
LINE=$(printf %75s |tr " " "-")
grn='\e[1;32m'
red='\e[1;31m'
end='\e[0m'


if [ -z "$1" ] ; then
    file=$(basename $0)
    echo "Sorry you need to give me a mac address or a partial mac"
    echo $LINE
    echo ""
    echo "Usage: ./$(basename $0) 54:27:1E"
    echo ""
    echo "       ./$(basename $0) 54:27:1e:34:f5"
    exit 1
fi

LINE2=$(printf %75s |tr " " ":")
if [ -f /opt/oui/oui.txt ]; then
    result=$(grep -i -A 4 ^$MAC /opt/oui/oui.txt)
    echo $LINE2
    echo "::     using /opt/oui/oui.txt for initital search for MAC    $1"
    echo $LINE2
fi


if [ "$result" ]; then
    echo "For the MAC ${grn}${1}${end} the following information was found"
    echo $LINE
    echo $grn
    echo "$result" $end
else
    echo $red "MAC $grn $1 $red is not found in the database." $end
fi


if  which updatedb > /dev/null; then
    LINE2=$(printf %75s |tr " " ":")
    echo $LINE2
    echo "::      Using locate to find oui.txt files and searching for $1"
    echo $LINE2
    sudo updatedb
    for x in $(locate oui.txt);
        do
            grep -i -E "${MAC}|${ORIGMAC}" $x;
        done
    echo $LINE
else
    LINE2=$(printf %75s |tr " " ":")
    echo $LINE2
    echo "::     Using find to locate oui.txt files and searching for $1"
    find / -type f -name oui.txt -exec grep -i -E "${MAC}|${ORIGMAC}" {} \;
    echo $LINE2
fi
EOF
chmod 755 ~/bin/maclookup.sh

    fi

    if [ ! -f ~/bin/setup-ftp.sh ] ; then

echo $grn[+]$end creating pure-ftpd setup script
cat << "EOF" > ~/bin/setup-ftp.sh
#!/bin/bash

groupadd ftpgroup
useradd -g ftpgroup -d /dev/null -s ftpuser
echo Addin offsec FTP User
pure-pw useradd offsec -u ftpuser -d /ftphome
pure-pw mkdb
cd /etc/pure-ftpd/auth
ln -s ../conf/PureDB 60pdb
mkdir -p /ftphome
chown -R ftpuser:ftpgroup /ftphome
/etc/init.d/pure-ftpd restart


#############################################################################
# from within windows you could create a file to feed the ftp server
# echo open 10.11.0.5  21 > ftp.txt
# echo user offsec >> ftp.txt
# echo ftp >> ftp.txt
# echo bin >> ftp.txt
# echo GET nc.exe >> ftp.txt
# echo bye >> ftp.txt
# ftp -v -n -s:ftp.txt
#############################################################################

EOF
chmod 755 ~/bin/setup-ftp.sh

    fi

    pull_git_repo https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle "Vundle package manager for VIM"
    # if ! [ -d ~/.vim/bundle/vundle ]; then
	# git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    # fi

    if [ ! -d ~/.ssh ]; then
        echo $grn[*]$end Checking for ~/.ssh directory
        mkdir ~/.ssh
        chmod 700 ~/.ssh
    fi

    if [ ! -f ~/.ssh/config ]; then
        echo $grn[*]$end Creating basic .ssh/config file for netivim
cat << "EOF" >> ~/.ssh/config
Host base
    HostName 172.16.80.146
    User user1
    IdentityFile ~/.ssh/id_rsa
    VisualHostKey=yes
Host dmza
    Hostname dmza
    User user1
    ProxyJump base
EOF
    fi

    if [ ! -f ~/bin/mount-vmware-shares.sh ]; then
    echo $grn[*]$end creating vmware share script
cat << "EOF" > ~/bin/mount-vmware-shares.sh
vmware-hgfsclient | while read folder; do
    echo "[+] Mounting ${folder} (/mnt/hgfs/${folder})"
    mkdir -p "/mnt/hgfs/${folder}"
    umount -f "/mnt/hgfs/${folder}" 2>/dev/null
    vmhgfs-fuse -o allow_other -o auto_unmount ".host:/${folder}" "/mnt/hgfs/${folder}"
done
EOF
chmod +x ~/bin/mount-vmware-shares.sh

fi

# echo $yel
# cat << "EOF"
#  ________                    .___.__
#  \______ \____________     __| _/|__| ______
#   |    |  \_  __ \__  \   / __ | |  |/  ___/
#   |    `   \  | \// __ \_/ /_/ | |  |\___ \
#  /_______/  /__|  (____  /\____ | |__/____  >
#          \/           \/      \/         \/
# EOF
# echo $end
# # Check if the dradis framework has been downloaded
#     echo $grn [*]$end Checking Dradis templates
#     if [ ! -f ~/Downloads/dradis-ce_compliance_package-oscp.v0.3.zip ]; then
#         cd Downloads
#         echo $grn [*]$end Dowloading Dradis OCSP templates for Dradis
#         wget https://dradisframework.com/academy/files/dradis-ce_compliance_package-oscp.v0.3.zip
#         cd
#     else
#         echo $yel [*]$end Dradis OCSP templates exists in downloads

#     fi
#     if [ ! -d ~/Downloads/dradis-ce_compliance_package-oscp.v0.3 ]; then
#         cd ~/Downloads
#         echo $grn [*]$end Unzipping dradis-ce_copliance_package-oscp.v03.zip
#         unzip dradis-ce_compliance_package-oscp.v0.3.zip
#         cd
#     fi

#     for TEMPLATE in evidence.txt note-tester.txt issue.txt note
#     do
#         if [ ! -f /var/lib/dradis/templates/notes/${TEMPLATE} ] ; then
#             echo $grn [*]$end Adding Dradis OCSP ${TEMPLATE} templates to Dradis
#             cp ~/Downloads/dradis-ce_compliance_package-oscp.v0.3/$TEMPLATE /var/lib/dradis/templates/notes
#         else
#             echo $yel "[*]${end} OCSP ${TEMPLATE} templates exists in Dradis"
#         fi
#     done
#     if [ ! -f /var/lib/dradis/templates/reports/html_export/dradis_template-oscp.v0.3.html.erb ] ; then
#         echo $grn [*]$end Updating Dradis Reporting templates
#         cp ~/Downloads/dradis-ce_compliance_package-oscp.v0.3/dradis_template-oscp.v0.3.html.erb /var/lib/dradis/templates/reports/html_export/
#     else
#         echo $yel [*]$end Dradis Reporting template exists
#     fi

fi

# if [ ! -f ~/bin/dradis-reset.sh ]; then
#     echo $grn [*]$end Creating dradis-reset.sh script in ~/bin
#     mkdir -p ~/bin
# cat << "EOF" > ~/bin/dradis-reset.sh
# #!/bin/bash
# #
# # The reset password is not working.. .so you need to run the following from
# # the /usr/lib/dradis directory
# # $ bin/rails console
# # Configuration.find_by_name('admin:password').update_attribute(:value, ::BCrypt::Password.create('password'))
# #
# #
# #
# #

# cd /usr/lib/dradis/
# echo $grn [*] $end Reset Dradis
# bundle exec thor dradis:reset
# echo $grn [*] $end Reset Dradis Attachments
# bundle exec thor dradis:reset:attachments
# echo $grn [*] $end Reset Dradis Database
# bundle exec thor dradis:reset:database
# echo $grn [*] $end Reset Dradis password
# bundle exec thor dradis:reset:password
# echo $grn [*] $end Reset Dradis again...
# bundle exec thor dradis:reset
# echo $grn [*] $end Launch Dradis
# dradis

# EOF
# else
#     echo $yel [*]$end Dradis-reset.sh script EXISTS

# fi

#---------- Done with the OS conditional shit

# echo $wht '[*] Check to see if Metasploit is installed' $end
if [ "$host" = "base" ] || [ "$host" = "exta" ]; then
    if ! which msfconsole > /dev/null; then
        echo $gry '[ ] metasploit not installed yet' $end
        echo [+] Downloading Metasploit
        curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
        chmod 755 msfinstall && \
        echo [+] Installing Metasploit
        ./msfinstall
    else
        echo $grn '[+] Metasploit is installed' $end
    fi

    # echo $wht '[*] Check if Tmux is installed' $end
    if ! which tmux > /dev/null; then
        echo [ ] tmux not installed
        echo [+] installing tmux
        sudo apt-get install tmux -y
    else
        echo $grn '[+] Tmux is already installed' $end
    fi

    # echo $wht '[*] Check if postgresql is installed' $end
    # if ! which postgresql > /dev/null; then
    if ! sudo apt-get -qq install postgresql-common ; then
        echo [ ] postgresql not installed
        echo [+] installing postgresql
        sudo apt-get install postgresql -y
    else
        echo $grn '[+] postgresql is already installed' $end
    fi

    if ! sudo apt-get -qq install htop ; then
        echo [ ] htop not installed
        echo [+] installing htop
        sudo apt-get install htop -y
    else
        echo $grn '[+] htop is already installed' $end
    fi

    # echo $wht '[*] Check if GIT is installed' $end
    if ! which git > /dev/null; then
        echo '[+] installing git'
        sudo apt-get install git -y
    else
        echo $grn '[+] git already installed' $end
    fi

    # echo $wht '[*] Check if VIM is installed' $end
    if ! which vim > /dev/null; then
        echo [+] installing vim
        sudo apt-get install vim -y
    else
        echo $grn '[+] vim already installed' $grn
    fi

    pull_git_repo https://www.github.com/octothorp88/dotfiles ~/dotfiles "Octothorp88 dotfiles"

    create_symlink ~/dotfiles/.vimrc ~/.vimrc 
    create_symlink ~/dotfiles/tmux.conf ~/.tmux.conf

    pull_git_repo https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

if [ "$host" = "base" ]; then
    # echo $wht '[*] Checking for metasploitable download' $end
    if [ ! -f ./metasploitable-linux-2.0.0.zip ] ; then
        echo $gry '[ ] downloading metasploitable from rapid7'
        wget http://downloads.metasploit.com/data/metasploitable/metasploitable-linux-2.0.0.zip
    else
        echo $grn '[+] metasploitable downloaded and exists' $end
    fi
    metasploitable2=2ae8788e95273eee87bd379a250d86ec52f286fa7fe84773a3a8f6524085a1ff

    echo     $mag '    KNOWN HASH:'$metasploitable2 $end
    download=`sha256sum ./metasploitable-linux-2.0.0.zip | awk '{print $1}'`
    if [ "$metasploitable2" = "$download" ]; then
        echo $mag'     LOCAL HASH:'$download $end
        echo $grn '[+] metasploitable hash verification PASSED' $end
        if [ ! -f Metasploitable2-Linux/Metasploitable.vmdk ]; then
            unzip ./metasploitable-linux-2.0.0.zip
        else
            echo $grn '[+] Metasploitable2 unzipped' $end
            if [ ! -f Metasploitable2-Linux/Metasploitable2.qcow2 ]; then
                echo $grn '[+] Converting metasploitable to qcow2 format' $end
                qemu-img convert -f vmdk -O qcow2 Metasploitable2-Linux/Metasploitable.vmdk Metasploitable2-Linux/Metasploitable2.qcow2
            else
                echo $grn '[+] Metasploitable previously converted to qcow2 format' $end
            fi
        fi
    else
        echo $red'     LOCAL HASH:'$download $end
        echo $red '[-] metasploitable hash verification FAILED' $end
    fi

    # echo $wht '[*] Checking for Kali Light  download' $end
    if [ ! -f ./kali-linux-light-2019.1-amd64.iso ] ; then
        echo [ ] downloading kali from kali.org
        wget http://cdimage.kali.org/kali-2019.1/kali-linux-light-2019.1-amd64.iso
    else
        echo $grn '[+] kali light downloaded and exists'
    fi

    kalilight=5e9fe4b6f099c3a0062dd21b68c61ea328fc145d60536d8f20f1ab27ad21b856
    echo $mag'     KNOWN HASH:'$kalilight $end
    download=`sha256sum ./kali-linux-light-2019.1-amd64.iso| awk '{print $1}'`
    if [ "$kalilight" = "$download" ]; then
        echo $mag'     LOCAL HASH:'$download $end
        echo $grn '[+] kali hash verification PASSED' $end
    else
        echo $red'     LOCAL HASH:'$download $end
        echo $red '[-] kali hash verification FAILED' $end
    fi

    # echo $wht '\n[*] Checking for Kali full download' $end
    if [ ! -f ./kali-linux-2019.1-vm-amd64.7z ] ; then
        echo $wht '[ ] downloading kali from kali.org' $end
        wget https://images.offensive-security.com/virtual-images/kali-linux-2019.1-vm-amd64.7z
    else
        echo $grn '[+] kali full downloaded and exists' $end
    fi


    kalifull=e4c6999edccf27f97d4d014cdc66950b8b4148948abe8bb3a2c30bbc0915e95a
    echo $mag'     KNOWN HASH:'$kalifull $end
    download=`sha256sum ./kali-linux-2019.1-vm-amd64.7z | awk '{print $1}'`
    if [ $kalifull = $download ]; then
        echo $mag'     LOCAL HASH:'$download $end
        echo $grn '[+] kali hash verification PASSED' $end
        if [ ! -f Kali-Linux-2019.1-vm-amd64/Kali-Linux-2019.1-vm-amd64.vmdk ]; then
            7z x ./kali-linux-2019.1-vm-amd64.7z
        else
            echo $grn '[+] Kali Full VM previously unzipped' $end
        fi

        if [ ! -f Kali-Linux-2019.1-vm-amd64/Kali-Linux-2019.1-vm-amd64.qcow2 ]; then
            echo $grn '[+] Converting Kali full to qcow2 format' $end
            qemu-img convert -f vmdk -O qcow2 Kali-Linux-2019.1-vm-amd64/Kali-Linux-2019.1-vm-amd64.vmdk Kali-Linux-2019.1-vm-amd64/Kali-Linux-2019.1-vm-amd64.qcow2 
        else
            echo $grn '[+] Kali Full previously converted to qcow2 format' $end
        fi
    else
        echo $red'     LOCAL HASH:'$download $end
        echo $red '[-] kali hash verification FAILED' $end
    fi

    if [ ! -f ~/.ssh/id_rsa ] ; then
        echo $wht '[ ] creating SSH keypair' $end
        ssh-keygen -f ~/.ssh/id_rsa -t rsa -b 4096
    else
        echo $grn '[ ] SSH keypair already present' $end
    fi

    echo $wht '[ ] Copy SSH keys to hosts' $end
    if [ -f ~/.ssh/id_rsa ] ; then
        for vm in dmza inta exta dmzf; do
            if !  virsh start $vm 2>&1 | grep 'already active' > /dev/null; then
                echo $yel '[+] waiting for VM to spin up' $end
                sleep 10
            else
                echo $grn '[+] VM is already running' $vm  $end
            fi
            ssh-copy-id -i ~/.ssh/id_rsa.pub user1@${vm}
        done
    else
        echo $red '[-] missing ~/.ssh/id_rsa' $end
    fi

    echo $wht '[ ] stage files to other hosts and install' $end
    for vm in dmza inta exta; do
        if ssh ${vm} stat ./msfinstall \> /dev/null 2\>\&1; then
            echo $grn '[+] msfinstall exists on ' ${vm}  $end
        else
            echo $grn '[+] copying msfinstall on ' ${vm}  $end
            scp ./msfinstall ${vm}:./
        fi
        if ssh ${vm} stat ./netinvm-initialize.sh \> /dev/null 2\>\&1; then
            echo $grn '[+] netinvm-initialize.sh exists on ' ${vm}  $end
        else
            echo $grn '[+] copying netinvm-intialize.sh on ' ${vm}  $end
            scp ./netinvm-initialize.sh ${vm}:./
        fi
    done
fi
