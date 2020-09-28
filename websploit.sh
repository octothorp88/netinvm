#!/usr/bin/env bash

# WebSploit installation script
# Author: Omar Ωr Santos
# Web: https://websploit.org
# Twitter: @santosomar
# Version: 2.5

clear
echo "

██╗    ██╗███████╗██████╗ ███████╗██████╗ ██╗      ██████╗ ██╗████████╗
██║    ██║██╔════╝██╔══██╗██╔════╝██╔══██╗██║     ██╔═══██╗██║╚══██╔══╝
██║ █╗ ██║█████╗  ██████╔╝███████╗██████╔╝██║     ██║   ██║██║   ██║
██║███╗██║██╔══╝  ██╔══██╗╚════██║██╔═══╝ ██║     ██║   ██║██║   ██║
╚███╔███╔╝███████╗██████╔╝███████║██║     ███████╗╚██████╔╝██║   ██║
 ╚══╝╚══╝ ╚══════╝╚═════╝ ╚══════╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝   ╚═╝

https://websploit.org
Author: Omar Ωr Santos
Twitter: @santosomar
Version: 2.6

A collection of intentionally vulnerable applications running in
Docker containers. These include over 400 exercises to learn and
practice ethical hacking (penetration testing) skills.

"
read -n 1 -s -r -p "Press any key to continue the setup..."

echo " "
# Setting Up vim with Python Jedi to be used in several training courses

cd ~/
apt update
apt install -y wget
apt install -y vim
apt install -y vim-python-jedi
apt install -y curl vim exuberant-ctags git ack-grep
apt install -y python-pip
apt install -y python3-pip
pip install pep8 flake8 pyflakes isort yapf

# Then get the .vimrc file from my repo:
curl https://raw.githubusercontent.com/The-Art-of-Hacking/websploit/master/.vimrc > ~/.vimrc

#installing Docker
#apt install -y docker.io

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' | sudo tee /etc/apt/sources.list.d/docker.list
apt update
apt remove docker docker-engine docker.io
apt install -y docker-ce

# setup containers
docker run --name webgoat -d --restart unless-stopped -p 8881:8080 -t santosomar/webgoat
docker run --name juice-shop --restart unless-stopped -d -p 8882:3000 santosomar/juice-shop
docker run --name dvwa --restart unless-stopped -itd -p 8883:80 santosomar/dvwa
docker run --name mutillidae_2 --restart unless-stopped -d -p 8884:80 santosomar/mutillidae_2
docker run --name bwapp2 --restart unless-stopped -d -p 8885:80 santosomar/bwapp
docker run --name dvna --restart unless-stopped -d -p 8886:9090 santosomar/dvna
docker run --name hackazon -d --restart unless-stopped -p 8887:80 santosomar/hackazon
docker run --name hackme-rtov -d --restart unless-stopped -p 8888:80 santosomar/hackme-rtov
docker run --name mayhem -d --restart unless-stopped -p 8889:80 -p 88:22 santosomar/mayhem
docker run --name rtv-safemode -d --restart unless-stopped -p 9000:80 -p 3306:3306 santosomar/rtv-safemode

# for bwapp - go to /install.php then user/pass is bee/bug

#downloading the h4cker wallpaper
cd /root/Pictures
wget https://h4cker.org/img/h4cker_wallpaper.png

#cloning H4cker github
cd /root
git clone https://github.com/The-Art-of-Hacking/h4cker.git

#getting test ssl script
curl -L https://testssl.sh --output testssl.sh
chmod +x testssl.sh


#Installing ffuf 
apt install -y ffuf

#Installing Jupyter Notebooks
apt install -y jupyter-notebook

#Installing radamnsa
cd /root
git clone https://gitlab.com/akihe/radamsa.git && cd radamsa && make && sudo make install

#Installing Ghidra
cd /root

# first install Java
wget https://download.websploit.org/jdk.deb
apt install -y ./jdk.deb

#then download and unzip ghidra
wget https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip
unzip ghidra*

#Installing EDB
apt install -y edb-debugger

#Installing gobuster
apt install -y gobuster

#Installing OWASP ZAP
apt install -y zaproxy

#Getting the container info script
cd /root
wget http://websploit.h4cker.org/containers.sh
chmod 744 containers.sh

# Adding an alias for ip command
echo "alias i='ip -c -brie a'" >> .bashrc
source .bashrc

# Downloading the upgrade script for the containers
cd /root
wget http://websploit.h4cker.org/upgrade-juice-shop.sh
chmod 744 containers.sh
clear

#Final confirmation
/root/containers.sh
echo "
All tools, apps, and containers have been installed and setup.
-----------------
"

echo "All set! Have fun! - Ωr"
