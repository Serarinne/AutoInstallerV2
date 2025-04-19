#!/bin/bash
clear
echo -e "——————————————————————————————————————"
echo -e "            Restore Server            "
echo -e "——————————————————————————————————————"
read -rp "URL Backup: " -e fileUrl
wget -O /root/backup.zip "$fileUrl"
unzip /root/backup.zip
sleep 1
echo -e "Restoring...."
cp -r /root/backup/config /usr/local/etc/xray >/dev/null 2>&1
cp -r /root/backup/public_html /home/vmess/public_html &> /dev/null
rm -rf /root/backup
rm -f /root/backup.zip
echo ""
echo -e "Restarting Service..."
systemctl restart nginx
systemctl restart xray.service
service cron restart
echo ""
read -p "$(echo -e "Back")"
menu