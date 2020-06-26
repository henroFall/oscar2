#!/bin/bash

rootCheck() {
    if ! [ $(id -u) = 0 ]
    then
        echo -e "\e[41m I am not root! Run with SUDO. \e[0m"
        exit 1
    fi
}

check_exit_status() {
    if [ $? -ne 0 ]
    then
        echo -e "\e[41m ERROR: PROCESS FAILED!"
        echo
        read -p "The last command exited with an error. Exit script? (yes/no)" answer
        if [ "$answer" == "yes" ]
        then
            echo -e "EXITING. \e[0m"
            echo
            exit 1
        fi
    fi
echo
}

####################################################

rootCheck
echo "               ____ "
echo "   ___________//__\\\\__________"
echo "  /___________________________\\"
echo "  I___I___I___I___I___I___I___I"
echo "        < ,wWWWWwwWWWWw, >"
echo "       <  WW( 0 )( 0 )WW  >"
echo "      <      '-'  '-'      >"
echo "     <    ,._.--\"\"--._.,    >"
echo "     <   ' \\   .--.   / \`   >"
echo "      <     './__\\_\\.'     >"
echo "    ___<.-.____________.-.>___"
echo "   (___/   \\__________/   \\___)"
echo "    |  \\,_,/          \\,_,/  |"
echo "  .-|/^\\ /^\\ /^\\ /^\\ /^\\ /^\\ |-."
echo " / (|/\\| | | | | | | | | | /\\|) \\"
echo " '.___/| | | | | | | | | | \\___.'"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    || | | | | | | | | | | | |"
echo "    |\\_/ \\_/ \\_/ \\_/ \\_/ \\_/ |"
echo "    |                        |"
echo
echo "Hello! Let's set up Oscar2!"
echo
echo "This script is tested on Raspbian, Ubuntu 20.04 & 18.04."
echo
read -p "Press <enter> to begin!"
echo
######################################## Branch Choice
echo "Oscar2 is going to pull a fresh copy from Github once we get started."
echo "You should, unless you know better, pull from the master branch."
echo "Push <enter> here to do that, or optionally type in the name of a branch"
echo "to pull from."
echo "Valid entries: master"
echo "               dev"
echo
read -p "Type in a branch name, or press <enter> for the default [master]:" gitbranch
######################################## Web port
echo "Oscar2 needs a TCP port for a web server. I can use port 80, but"
echo "that is some pretty prime real estate for a TRASH sCANer. You"
echo "can enter any valid TCP port number here, or press <enter> to"
echo "use 8543, the default."
read -p "Port number [8543]:" webport
if [ -z "$webport" ]
then webport=8543
fi

######################################## Scanner Detect
echo
echo "OK! Now, we are now going to attept to detect your USB barcode scanner."
echo "Be sure it is UNPLUGED, then press <enter>."
read
echo "Standby..."
sleep 2
rm -f ~/before.txt
rm -f ~/after.txt
ls -1 /dev/input > ~/before.txt
sleep 1
echo
echo "Now, please PLUG IT IN, then press <enter>."
read
echo "Standby..."
sleep 2
ls -1 /dev/input > ~/after.txt
usbPort=$(comm -13  ~/before.txt ~/after.txt)
if [ -z "$usbPort" ]
then
      echo
      echo "I didn't see anything change, so we will assume this is Raspbian or"
          echo "another OS that defaults to event0 for the device input." 
          echo "Using event0..."
          usbPort="event0"
else
      echo "I see a new device attached to $usbPort, so we are going to use that."
fi
echo
place="/dev/input/"
usbPlace="${place}${usbPort}"
echo "Set device to: $usbPlace"

######################################## Dependencies
echo
echo "We need to install some dependencies and stitch together all the magic."
echo "This can take upwards of anhour on a Raspberry Pi, since it involves"
echo "compiling stuff. It only takes about a minute on a decent x86."
echo "Press <enter> when you're ready. Press 'Ctrl+C' to cancel."
read 
echo
echo "You should almost for sure strip nodejs and node from the system before"
read -ep "installing Oscar. Is that OK to do now [yes]?" yesno
if [[ $yesno == "" ]]; then
       yesno='yes'
	   check_exit_status
fi	
if [[ $yesno == "y" ]]; then
       yesno='yes'
fi
if [[ $yesno == "Yes" ]]; then
       yesno='yes'
fi
if [[ $yesno == "YES" ]]; then
       yesno='yes'
fi
if [[ $yesno == "yES" ]]; then
       yesno='yes'
fi
apt update
if [[ $yesno == "yes" ]]; then
       echo "Stripping nodejs & npm from system and reinstalling with other dependencies..."
	   check_exit_status
	   apt remove -y npm
	   check_exit_status
	   apt remove -y nodejs-legacy
	   check_exit_status
	   apt remove -y nodejs
	   check_exit_status
	   rm /usr/bin/node
fi
echo
if [[ $(lsb_release -rs) == "20.04" ]]; then 

       echo "Ubuntu 20.04 detected, installing package: python2."
       apt -y install python2
	   check_exit_status
else
       echo "$(lsb_release -rs) detected. Installing package: python."
	   apt -y install python
	   check_exit_status
fi
apt -y install sed curl git supervisor build-essential nodejs npm
check_exit_status
curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
check_exit_status

if [[ $(lsb_release -rs) == "20.04" ]]; then 
python2 get-pip.py
else
python get-pip.py
fi
check_exit_status
pip install PyYAML --no-cache-dir trello==0.9.1 twilio
check_exit_status

######################################## Oscar itself
cd /var
if [ -d "/var/oscar" ]; then rm -Rf /var/oscar; fi
#git clone https://github.com/henroFall/oscar2.git oscar
git clone -b $gitbranch https://github.com/henroFall/oscar2.git oscar
check_exit_status
cd /var/oscar/web
######################################## Web
sed -i "s/80/$webport/g" /var/oscar/web/app.js
check_exit_status
npm install
check_exit_status
echo
cd /var/oscar/install
check_exit_status
supervisorctl reload
check_exit_status
chmod +x ./build.py
if [[ $(lsb_release -rs) == "20.04" ]]; then 
python2 ./build.py $usbPlace
else python ./build.py $usbPlace
fi
cd /var/oscar/web
sed -i "s/79/$webport/g" /etc/oscar.yaml
supervisorctl reload
check_exit_status
rm -f ~/before.txt
rm -f ~/after.txt
