# Create user
useradd manitra
useradd manitra sudo

# Configure sshd 
groupadd sshusers
useradd manitra sshusers
echo "AllowGroups sshusers" >> /etc/ssh/sshd_config

# Configure ufw to allow ssh, http and https only
ufw allow 22
ufw allow 80
ufw allow 443
ufw enable

# Install KVM (https://help.ubuntu.com/community/KVM/Installation#Installation_of_KVM)
apt-get install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

# Creates VM instances
# http://www.naturalborncoder.com/virtualization/2014/10/27/installing-and-running-kvm-on-ubuntu-14-04-part-4/
mkdir /var/vms

# vm01 => nginx, PHP, MySql
vmbuilder kvm ubuntu \
	--cpus 2 --arch amd64 \
	--rootsize 65536 \
	--mem 4096 \
	--hostname vm01 \
	--ip 192.168.122.101 \
	--user manitra --name Manitra --pass default \
	--firstboot `pwd`/vm1/boot.sh --firstlogin `pwd`/vm1/login.sh \
	--suite trusty --flavour virtual \
	--addpkg acpid --addpkg openssh-server --addpkg linux-image-generic \
	--mirror "ftp://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu" --components main,universe \
	--libvirt qemu:///system \
	--destdir /var/vms/vm01

# vm02 => mono
vmbuilder kvm ubuntu \
	--cpus 1 --arch amd64 \
	--rootsize 16384 \
	--mem 1024 \
	--hostname vm02 \
	--ip 192.168.122.102 \
	--user manitra --name Manitra --pass default \
	--suite trusty --flavour virtual \
	--addpkg acpid --addpkg openssh-server --addpkg linux-image-generic \
	--mirror "ftp://ubuntu.mirrors.ovh.net/ftp.ubuntu.com/ubuntu" --components main,universe \
	--libvirt qemu:///system \
	--destdir /var/vms/vm-02

# Port forwarding
PUB_IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
VLAN_RANGE="192.168.122.0/24"
iptables -t nat -I PREROUTING -p tcp -d $PUB_IP --dport 80 -j DNAT --to-destination 192.168.122.101:80
iptables -I FORWARD -m state -d $VLAN_RANGE --state NEW,RELATED,ESTABLISHED -j ACCEPT

