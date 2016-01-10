# This script will run the first time the virtual machine boots
# It is ran as root.

echo "First boot actions .."

# Expire the user account
passwd -e manitra

# Regenerate ssh keys
rm /etc/ssh/ssh_host*key*
dpkg-reconfigure -fnoninteractive -pcritical openssh-server