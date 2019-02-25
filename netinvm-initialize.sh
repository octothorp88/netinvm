#!/bin/sh

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
        echo $grn '[+] Pulling dotfiles from github' $grn
        git clone https://www.github.com/octothorp88/dotfiles ~/dotfiles
    else
        echo $grn '[+] dotfiles directory already exists' $grn
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
