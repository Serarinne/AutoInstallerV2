#!/bin/bash
clear
currentDate=$(date +"%Y-%m-%d-%H:%M:%S")
serverName=$(cat /usr/local/etc/xray/name)

echo -e "——————————————————————————————————————"
echo -e "            Backup Server             "
echo -e "——————————————————————————————————————"
sleep 1
echo -e "Processing backup..."
mkdir -p /root/backup
sleep 1
clear
cp -r /usr/local/etc/xray /root/backup/config >/dev/null 2>&1
cp -r /home/vmess/public_html /root/backup/public_html

zip -r /root/$serverName-$currentDate.zip /root/backup > /dev/null 2>&1

curl --write-out %{http_code} --silent --output /dev/null --request PUT --url https://storage.bunnycdn.com/serafile/vmess/${serverName}-${currentDate}.zip --header 'AccessKey: 2e63f1d0-89f4-48b8-809ff7f8abbb-1847-410a' --header 'Content-Type: application/octet-stream' --header 'accept: application/json' --data-binary @"/root/${serverName}-${currentDate}.zip"

rm -rf /root/backup
rm -r /root/${serverName}-${currentDate}.zip
echo ""
read -p "$(echo -e "Back")"
menu
