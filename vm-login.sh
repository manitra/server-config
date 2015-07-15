# This script is ran the first time a user logs in

echo "Your appliance is about to be finished to be set up."
echo "In order to do it, we'll need to ask you a few questions,"
echo "starting by setting you keyboard and other console informations."

#give the opportunity to change the keyboard
sudo dpkg-reconfigure console-setup


echo "Your appliance is now configured.  To use it point your"
echo "browser to http://serverip/limesurvey/admin"