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

cleanup() {
rm -f /var/oscar/mergetrelloboards/tapp.txt
rm -f /var/oscar/mergetrelloboards/ttd.txt
rm -f /var/oscar/mergetrelloboards/ttoken.txt
rm -f /var/oscar/mergetrelloboards/tgb.txt
rm -f /var/oscar/mergetrelloboards/tgl.txt
rm -f install_wd.sh
}
####################################################
rootCheck
user=${SUDO_USER:-${USER}}
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
read -p "Press <enter> to begin, and push <enter> for most of this!"
echo
######################################## Branch Choice
echo "Oscar2 is going to pull a fresh copy from Github once we get started."
echo "You should, unless you know better, pull from the master branch."
echo "Push <enter> here to do that, or optionally type in the name of a branch"
echo "to pull from."
echo
echo "Valid entries: master"
echo "               dev"
echo
read -p "Type in a branch name, or press <enter> for the default [master]: " gitbranch
if [[ $gitbranch  == "" ]]; then desktopYN='master'
if [[ $gitbranch  == "DEV" ]]; then desktopYN='dev'
if [[ $gitbranch  == "dEV" ]]; then desktopYN='dev'
if [[ $gitbranch  == "Dev" ]]; then desktopYN='dev'
if [[ $gitbranch  == "dEv" ]]; then desktopYN='dev'
if [[ $gitbranch  != "dev" ]]; then desktopYN='master'
echo Using branch: $gitbranch .
fi



######################################## Web port
echo
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
sleep 1
echo

######################################## Desktop Choice
desktopins = $((ls /usr/bin/*session) | grep gnome )
desktopins 

echo "Oscar2 can optionally install a Kitchen-counter"
echo "Desktop Experience! With this, you can install"
echo "Conky with Trello Lists on your desktop, weather"
echo "widgets, and more, along with the DeskWeather"
echo "module with FireWatch wallpapers, to always have a"
echo "reflection of the weather outside right on your monitor's"
echo "background. Each sub-module will offer its own confirmation"
echo "and choices, but before we get to all of that, do you overall"
echo "wish to install the Desktop component foundation? Say 'No'"
echo "if you do not have a GUI installed on this machine and you do"
echo " not intend to connect an always-on monitor to Oscar."
echo
read -p "Install Oscar Desktop widget y/n? [y]:" desktopYN
if [[ $desktopYN  == "" ]]; then desktopYN='y'
fi
if [[ $desktopYN  == "Yes" ]]; then desktopYN='y'
fi
if [[ $desktopYN  == "YES" ]]; then desktopYN='y'
fi
if [[ $desktopYN  == "yES" ]]; then desktopYN='y'
fi
if [[ $desktopYN  == "Y" ]]; then desktopYN='y'
fi
if [[ $desktopYN  == "Yes" ]]; then desktopYN='y'
fi
echo
if [[ $desktopYN  == "y" ]]; then echo "Oscar Desktop WILL be configured." 
  else echo "Oscar Desktop WILL NOT be configured." 
fi

######################################## Dependencies
echo
echo "We need to install some dependencies and stitch together all the magic."
echo
echo "Before we start, you should almost for sure let me strip nodejs and node"
echo "from the system. But, if you have something else using node on this machine,"
echo "I'm going to break it now. If you aren't sure, you're fine. Go ahead and hit <enter>."
echo "There is probably no good reason to say 'No,' here... But if you can think of a reason,"
echo "feel free... Either way, this can take upwards of an hour on a Raspberry Pi, since"
echo "it involves compiling stuff. It only takes about a minute on a decent x86."
echo
read -ep "Is that OK to purge node/nodejs to start clean (push enter now, seriously, don't say 'no') [yes]?" yesno
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
echo
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
apt -y install sed curl git supervisor build-essential nodejs npm python3-pip
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
pip install requests --no-cache-dir
check_exit_status
pip install jsmin --no-cache-dir
check_exit_status
pip3 install requests --no-cache-dir
check_exit_status
pip3 install jsmin --no-cache-dir
check_exit_status

######################################## Oscar itself
cd /var
if [ -d "/var/oscar" ]; then rm -Rf /var/oscar; fi
git clone -b $gitbranch https://github.com/henroFall/oscar2.git oscar
check_exit_status
cd /var/oscar
git clone https://github.com/henroFall/mergetrelloboards.git
check_exit_status

cd /var/oscar/web
######################################## Web
sed -i "s/80/$webport/g" /var/oscar/web/app.js
check_exit_status
npm install
check_exit_status
supervisorctl reload
check_exit_status
cd /var/oscar/install
check_exit_status
chmod +x ./build.py

######################################## Call Build.py
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

######################################## Oscar Desktop
if [[ $desktopYN == "y" ]]; then
echo "Installing Oscar Desktop configuration..."
echo
trelloappkey=$(cat /var/oscar/mergetrelloboards/tapp.txt)
trellodesktopkey=$(cat /var/oscar/mergetrelloboards/ttd.txt)
trellotoken=$(cat /var/oscar/mergetrelloboards/ttoken.txt)
trellogroceryb=$(cat /var/oscar/mergetrelloboards/tgb.txt)
trellogroceryl=$(cat /var/oscar/mergetrelloboards/tgl.txt)

echo Loading Trello desktop api key: $trellodesktopkey
sed -i "s/64252214ed1b10024ee8742f8db14a6b/$trellodesktopkey/g" /var/oscar/mergetrelloboards/conf.json
check_exit_status
echo Loading Trello token: $trellotoken
sed -i "s/172df2e4d4004f66525c74a4945212992301b16508ab087fe6f681d14a457f0e/$trellotoken/g" /var/oscar/mergetrelloboards/conf.json
check_exit_status
echo Loading Trello grocery board: $trellogroceryb
sed -i "s/GKuapt0N/$trellogroceryb/g" /var/oscar/mergetrelloboards/conf.json
check_exit_status
echo Loading Trello grocery list:  $trellogroceryl
sed -i 's|    "Q1: Important / Urgent / En attente" : "BY_COLOR",|    \"Groceries\" : \"BY_DATE\",|g' /var/oscar/mergetrelloboards/conf.json
check_exit_status
sed -i 's|    "Q2: Important / Pas urgent": "BY_COLOR",|    \"Housewares\" : \"BY_DATE\",|g' /var/oscar/mergetrelloboards/conf.json
check_exit_status
sed -i 's|    "Calendrier": "BY_DATE"||g' /var/oscar/mergetrelloboards/conf.json
check_exit_status

######################################## Conky Widgets
echo
echo "Now we can optionally install some Conky Desktop Widgets. You'll get your Trello Grocery List, plus"
echo "the extra Housewares list that we made before as desktop widgets. This way you can always see what's"
echo "on the list at a glance."
echo
read -p "Should we set up the widgets y/n? [y]:" desktopYNc
if [[ $desktopYNc  == "" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "Yes" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "YES" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "yES" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "Y" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "Yes" ]]; then desktopYNc='y'
fi
if [[ $desktopYNc  == "y" ]]; then
echo  $user ran the script, installing Conky for $user.
 mkdir /home/$user/Conky
 cp /var/oscar/conky/conkyrc* /home/$user/Conky
 chmod +x /var/oscar/conky/conky.sh
 cp /var/oscar/conky/oscar-conky.desktop /home/$user/.config/autostart
 echo
 echo "Conky is set up. You will see Conky widgets on your next reboot."
 echo
 echo "If you need to edit their positions, colors, etc., you can do so"
 echo "by editing the contents of the ~/Conky folder."
 echo 
fi

######################################## Weather Desktop w/ FireWatch
wget -N https://raw.githubusercontent.com/henroFall/weatherDesktopInstaller/master/install/install_wd.sh
check_exit_status
sudo chmod +x install_wd.sh 
check_exit_status
./install_wd.sh

Cleanup