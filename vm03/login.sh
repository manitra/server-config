#! /bin/sh

# VestaCP installation : https://vestacp.com/install/

curl -O http://vestacp.com/pub/vst-install.sh
bash vst-install.sh --nginx yes --apache yes --phpfpm no --named yes --remi no --vsftpd yes --proftpd no --iptables yes --fail2ban yes --quota no --exim yes --dovecot yes --spamassassin yes --clamav yes --mysql yes --postgresql no --hostname vm04.manitra.net --email default@mail.com --password default