# Create user
useradd manitra
useradd manitra sudo

# Configure sshd 
echo "AllowGroups sshusers" >> /etc/ssh/sshd_config
groupadd sshusers
useradd manitra sshusers

# Configure ufw to allow ssh, http and https only
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

# Install KVM (https://help.ubuntu.com/community/KVM/Installation#Installation_of_KVM)
apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils virt-viewer

# Creates the first VM
vmbuilder kvm ubuntu -c vm-01/vm.cfg

