# This script is ran the first time a user logs in

echo "Your appliance is about to be finished to be set up."
echo "In order to do it, we'll need to ask you a few questions,"
echo "starting by setting you keyboard and other console informations."

#give the opportunity to change the keyboard
sudo dpkg-reconfigure console-setup

# Installing EasyEngine is like PhpMyAdmin but for linux, https://github.com/rtCamp/easyengine
wget -qO ee rt.cx/ee && sudo bash ee     # Install easyengine 3
sudo ee site create web01.manitra.net --wp     # Install required packages & setup WordPress on example.com