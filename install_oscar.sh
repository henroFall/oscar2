#!/bin/bash
rootCheck() {
    if ! [ $(id -u) = 0 ]
    then
        echo -e "\e[41m I am NOT root! Run with SUDO. \e[0m"
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
}

maximize_vert() {
    wmctrl -r :ACTIVE: -b toggle,maximized_vert
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
if ! [ -z $XDG_CURRENT_DESKTOP ]; then
apt install wmctrl
fi
if ! [ -z $XDG_CURRENT_DESKTOP ]; then
maximize_vert
fi
username=${SUDO_USER:-${USER}}
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
######################################## Branch Choice
echo
echo "######################################## Branch Choice"
echo "Oscar2 is going to pull a fresh copy from Github once we get started."
echo "You should, unless you know better, pull from the master branch."
echo "Push <enter> here to do that, or optionally type in the name of a branch"
echo "to pull from."
echo
echo "Valid entries: master"
echo "               dev"
echo
read -p "Type in a branch name, or press <enter> for the default [master]: " gitbranch
if [ -z "$gitbranch" ]; then gitbranch='master'
fi
if [[ $gitbranch  == "DEV" ]]; then gitbranch='dev'
fi
if [[ $gitbranch  == "dEV" ]]; then gitbranch='dev'
fi
if [[ $gitbranch  == "Dev" ]]; then gitbranch='dev'
fi
if [[ $gitbranch  == "dEv" ]]; then gitbranch='dev'
fi
if [[ $gitbranch  != "dev" ]]; then gitbranch='master'
fi
echo Using branch: $gitbranch .

######################################## Web port
echo
echo "######################################## Web port"
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
echo "######################################## Scanner Detect"
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

######################################## Desktop Choice
echo
echo "######################################## Desktop Choice"
echo
if ! [ -z $XDG_CURRENT_DESKTOP ]; then
 echo "Oscar2 can optionally install a Kitchen-counter"
 echo "Desktop Experience! With it, you will see your Groceries and"
 echo "Housewares lists on your desktop background. You can also add"
 echo "a feature to set custom backgrounds based on the current time"
 echo "and weather at your location!"
 echo
 echo "I have detected that you do have a GUI enviornment on"
 echo "this instance / machine. However, say 'No' to this prompt"
 echo "if you don't intend to connect a monitor to Oscar, or you just don't"
 echo "want any of the Desktop Experience." 
 echo
 read -p "Install Oscar Desktop Experience y/n? [y]:" desktopYN
 if [ -z "$desktopYN" ]; then desktopYN='y'
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
   conkyall="conky-all" 
   else echo "Oscar Desktop WILL NOT be configured." 
 fi
 else 
 echo "I have detected no desktop enviornment, so we are skipping the Desktop Experience install."
 desktopYN='n'
fi

######################################## Dependencies
echo
echo "######################################## Dependencies"
echo
echo "We need to install some dependencies and stitch together all the magic."
echo
echo "Before we start, you should almost for sure let me strip nodejs and node"
echo "from the system. But, if you have something else using node on this machine,"
echo "I'm going to break it now. If you aren't sure, you're fine. Go ahead and hit"
echo "<enter> There is probably no good reason to say 'No,' here... But if you"
echo "can think of a reason, go ahead..."
echo "Either way, this can take upwards of an hour on a Raspberry Pi, since"
echo "it involves compiling stuff. It only takes about a minute on a decent x86."
echo
read -ep "Is that OK to purge node/nodejs to start clean (just push <enter>) [yes]?" yesno
if [ -z "$yesno" ]; then
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
apt -y install sed curl git supervisor build-essential software-properties-common nodejs npm python3-pip bc jq $conkyall
check_exit_status
curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
check_exit_status

if [[ $(lsb_release -rs) == "20.04" ]]; then 
python2 get-pip.py
else
python get-pip.py
python3 get-pip.py
fi
check_exit_status
pip2 install PyYAML --no-cache-dir
pip2 install trello==0.9.1 twilio --no-cache-dir
check_exit_status
pip2 install requests --no-cache-dir
check_exit_status
pip2 install jsmin --no-cache-dir
check_exit_status
python3 -m pip install requests --no-cache-dir
check_exit_status
python3 -m pip install jsmin --no-cache-dir
check_exit_status
rm -f get-pip.py
######################################## Oscar itself
echo "######################################## Oscar itself"
cd /var
if [ -d "/var/oscar" ]; then rm -Rf /var/oscar; fi
git clone -b $gitbranch https://github.com/henroFall/oscar2.git oscar
check_exit_status
cd /var/oscar
git clone https://github.com/henroFall/mergetrelloboards.git
check_exit_status
mkdir /var/oscar/mergetrelloboards2
check_exit_status
cp -R /var/oscar/mergetrelloboards/* /var/oscar/mergetrelloboards2/
check_exit_status

######################################## Web
echo
echo "######################################## Web"
cd /var/oscar/web
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
echo
echo "######################################## Build"
if [[ $(lsb_release -rs) == "20.04" ]]; then 
echo "Calling build.py with python2."
python2 ./build.py $usbPlace
else 
echo "Calling build.py with python."
python ./build.py $usbPlace
fi
echo
cd /var/oscar/web
sed -i "s/79/$webport/g" /etc/oscar.yaml
echo
read -ep "Press <enter> to continue." getpast
supervisorctl reload
check_exit_status
rm -f ~/before.txt
rm -f ~/after.txt

######################################## Oscar Desktop
echo "######################################## Oscar Desktop"
if [[ $desktopYN == "y" ]]; then
echo "Installing Oscar Desktop configuration..."
echo
trelloappkey=$(cat /var/oscar/mergetrelloboards/tapp.txt)
trellodesktopkey=$(cat /var/oscar/mergetrelloboards/ttd.txt)
trellotoken=$(cat /var/oscar/mergetrelloboards/ttoken.txt)
trellogroceryb=$(cat /var/oscar/mergetrelloboards/tgb.txt)
trellogroceryl=$(cat /var/oscar/mergetrelloboards/tgl.txt)

echo Loading Trello desktop api key: $trelloappkey
sed -i "s/64252214ed1b10024ee8742f8db14a6b/$trelloappkey/g" /var/oscar/mergetrelloboards/conf.json
sed -i "s/64252214ed1b10024ee8742f8db14a6b/$trelloappkey/g" /var/oscar/mergetrelloboards2/conf.json
check_exit_status
echo Loading Trello token: $trellodesktopkey
sed -i "s/172df2e4d4004f66525c74a4945212992301b16508ab087fe6f681d14a457f0e/$trellodesktopkey/g" /var/oscar/mergetrelloboards/conf.json
sed -i "s/172df2e4d4004f66525c74a4945212992301b16508ab087fe6f681d14a457f0e/$trellodesktopkey/g" /var/oscar/mergetrelloboards2/conf.json
check_exit_status
echo Loading Trello grocery board: $trellogroceryb
sed -i "s/GKuapt0N/$trellogroceryb/g" /var/oscar/mergetrelloboards/conf.json
sed -i "s/GKuapt0N/$trellogroceryb/g" /var/oscar/mergetrelloboards2/conf.json
check_exit_status
echo Loading Trello grocery list:  $trellogroceryl
sed -i 's|    "Q1: Important / Urgent / En attente" : "BY_COLOR",|    \"Groceries\" : \"BY_DATE\"|g' /var/oscar/mergetrelloboards/conf.json
check_exit_status
sed -i 's|    "Q2: Important / Pas urgent": "BY_COLOR",||g' /var/oscar/mergetrelloboards/conf.json
check_exit_status
sed -i 's|    "Calendrier": "BY_DATE"||g' /var/oscar/mergetrelloboards/conf.json
check_exit_status
echo Readying Trello Housewares manual list:  Housewares
sed -i 's|    "Q1: Important / Urgent / En attente" : "BY_COLOR",|    \"Housewares\" : \"BY_DATE\"|g' /var/oscar/mergetrelloboards2/conf.json
check_exit_status
sed -i 's|    "Q2: Important / Pas urgent": "BY_COLOR",||g' /var/oscar/mergetrelloboards2/conf.json
check_exit_status
sed -i 's|    "Calendrier": "BY_DATE"||g' /var/oscar/mergetrelloboards2/conf.json
check_exit_status
######################################## Conky Widgets
echo
echo "######################################## Conky"
echo  $username ran the script, installing Conky for $username.
 mkdir -p /home/$username/Conky
 check_exit_status
 if ! [ -d -a "/home/$username/.config" ]; then mkdir -p /home/$username/.config 
 fi
 check_exit_status
 mkdir -p /home/$username/.config/autostart
 check_exit_status
 cp /var/oscar/conky/conkyrc* /home/$username/Conky
 check_exit_status
 chmod +x /var/oscar/conky/conky.sh
 cp /var/oscar/conky/oscar-conky.desktop /home/$username/.config/autostart/oscar-conky.desktop
 check_exit_status
 cd /var/oscar/install
 git clone https://github.com/henroFall/Harmattan.git
 mkdir -p /home/$username/.harmattan-assets
 cp -r /var/oscar/install/Harmattan/.harmattan-assets/* /home/$username/.harmattan-assets/
 echo
 echo "Conky is set up. You will see Conky widgets on your next reboot."
 echo
 echo "If you need to edit their positions, colors, etc., you can do so"
 echo "by editing the contents of the ~/Conky folder."
 echo 
 read -ep "Press <enter> to continue." getpast

######################################## Weather Desktop w/ FireWatch
wget -N https://raw.githubusercontent.com/henroFall/weatherDesktopInstaller/master/install/install_wd.sh
check_exit_status
sudo chmod +x install_wd.sh 
check_exit_status
./install_wd.sh
else echo "Skipped Oscar Desktop configuration; Oscar2 will run in headless mode..."
fi
cleanup
echo
echo "All done! I'm ready to reboot."
read -p "PRESS <ENTER> TO REBOOT NOW." enditalreadyomg
echo
sudo reboot
