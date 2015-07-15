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
vmbuilder kvm ubuntu \
	--rootsize 16384 \
	--mem 2024 --cpus 1 --arch amd64 \
	--bridge br0 --ip 192.168.0.10 \
	--domain manitra.net --hostname srv01 \
	--user manitra --name Manitra --pass default \
	--firstboot vm-boot.sh --firstlogin vm-login.sh \
	--suite vivid --flavour virtual \
	--addpkg acpid --addpkg openssh-server \
	--mirror ftp://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu --components main,universe,restricted \
	--libvirt qemu:///system \
	--destdir /var/vms/vm-01

