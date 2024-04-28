#!/bin/bash

sudo yum install cifs-utils

cat >/etc/smb_credentials <<'EOF'
domain=*.gilead.com
username= 
password=
EOF

chown root:root /etc/smb_credentials
chmod 600 /etc/smb_credentials          # user: read/write, group+others: no access

sudo mkdir /mnt/share
sudo mount -t cifs //[WindowsServer_IP_Address]/[share_path] /mnt/share -o 'credentials=/etc/smb_credentials,vers=3.0'

output_file="disk_util_info.csv"

DEVICE_NAMES=$(df --output=source | grep ^/dev)
HOST=$(hostname)

for devname in $DEVICE_NAMES
do
    ALLOCATED=$(df $devname | awk 'NR>1 {printf "%i",$2}')
    USED=$(df $devname | awk 'NR>1 {printf "%i",$3}')
    AVAILABLE=$(df $devname | awk 'NR>1 {printf "%i",$4}')
    UTIL=$(df $devname | awk 'NR>1 {printf "%i",$5}')
    echo "$HOST, $devname, $ALLOCATED, $USED, $AVAILABLE, $UTIL%" >> "/mnt/share/$output_file"
done

sudo umount -f /mnt/share
