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
	--ip 192.168.122.101 --net 192.168.122.0 --mask 255.255.255.0 --gw 192.168.122.1 --bcast 192.168.122.255 --dns 192.168.122.1 \
	--user manitra --name Manitra --pass default \
	--suite trusty --flavour virtual \
	--addpkg acpid --addpkg linux-image-generic --addpkg vim --addpkg mono-complete \
	--mirror "ftp://distrib-coffee.ipsl.jussieu.fr/pub/linux/ubuntu" --components main,universe \
	--libvirt qemu:///system \
	--destdir /var/vms/vm01
virsh start vm01
virsh autostart vm01
echo "192.168.122.101 vm01.web01.manitra.net vm01" >> /etc/hosts

# vm02 => Jenkins machine
vmbuilder kvm ubuntu \
	--cpus 1 --arch amd64 \
	--rootsize 16384 \
	--mem 1024 \
	--hostname vm02 \
	--ip 192.168.122.102 --net 192.168.122.0 --mask 255.255.255.0 --gw 192.168.122.1 --bcast 192.168.122.255 --dns 192.168.122.1 \
	--user manitra --name Manitra --pass default \
	--suite trusty --flavour virtual \
	--addpkg acpid --addpkg linux-image-generic --addpkg openssh-server --addpkg vim --addpkg git --addpkg mono-complete --addpkg npm \
	--mirror "ftp://distrib-coffee.ipsl.jussieu.fr/pub/linux/ubuntu" --components main,universe \
	--libvirt qemu:///system \
	--destdir /var/vms/vm-02
virsh start vm02
virsh autostart vm02
echo "192.168.122.102 vm02.web01.manitra.net vm02" >> /etc/hosts

# vm03 => backup device
vmbuilder kvm ubuntu \
	--cpus 1 --arch amd64 \
	--rootsize 1048576 \
	--mem 1024 \
	--hostname vm03 \
	--ip 192.168.122.103 --net 192.168.122.0 --mask 255.255.255.0 --gw 192.168.122.1 --bcast 192.168.122.255 --dns 192.168.122.1 \
	--user manitra --name Manitra --pass default \
	--suite trusty --flavour virtual \
	--addpkg acpid --addpkg linux-image-generic --addpkg openssh-server --addpkg vim \
	--mirror "ftp://distrib-coffee.ipsl.jussieu.fr/pub/linux/ubuntu" --components main,universe \
	--libvirt qemu:///system \
	--destdir /var/vms/vm-03
virsh start vm03
virsh autostart vm03
echo "192.168.122.103 vm03.web01.manitra.net vm03" >> /etc/hosts

# Port forwarding 
# - vm01 is the main web server
# - vm03 is BitTorrent Sync administration on port 8888
# then we save it to /etc/iptables.rules that we load on startup
PUB_IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
VLAN_RANGE="192.168.122.0/24"
iptables -t nat    -I PREROUTING -p tcp -d $PUB_IP --dport 80 -j DNAT --to-destination 192.168.122.101:80
iptables -t nat    -I PREROUTING -p tcp -d $PUB_IP --dport 8002 -j DNAT --to-destination 192.168.122.102:8080
iptables -t nat    -I PREROUTING -p tcp -d $PUB_IP --dport 8003 -j DNAT --to-destination 192.168.122.103:8888
iptables -t filter -I FORWARD -m state -d $VLAN_RANGE --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables-save > /etc/iptables.rules
cp iptablesload /etc/network/if-pre-up.d/
chmod +x /etc/network/if-pre-up.d/iptablesload

