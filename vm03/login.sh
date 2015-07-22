#! /bin/sh


# install BitTorrent Sync (http://askubuntu.com/questions/284683/how-to-run-bittorrent-sync)
mkdir bt
cd bt
wget https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz
tar xzpf BitTorrent-Sync_x64.tar.gz
rm BitTorrent-Sync_x64.tar.gz
./btsync --dump-sample-config > btsync.conf