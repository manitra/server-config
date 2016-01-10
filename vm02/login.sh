# This script is ran the first time a user logs in

echo "Your appliance is about to be finished to be set up."
echo "In order to do it, we'll need to ask you a few questions,"
echo "starting by setting you keyboard and other console informations."

#give the opportunity to change the keyboard
sudo dpkg-reconfigure console-setup

# installing dependencies (apache + java)
sudo apt-get install apache2
sudo apt-get install openjdk-7-jdk
sudo apt-get update
sudo apt-get upgrade

# installing jenkins (https://www.rosehosting.com/blog/install-jenkins-on-an-ubuntu-14-04-vps/)
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
apt-get install jenkins

# enabling https with mono (for nuget packages restore)
sudo mozroots --import --machine --sync
sudo certmgr -ssl -m https://go.microsoft.com
sudo certmgr -ssl -m https://nugetgallery.blob.core.windows.net
sudo certmgr -ssl -m https://nuget.org


# installing bower globally (npm should have been installed previously)
npm install -g bower