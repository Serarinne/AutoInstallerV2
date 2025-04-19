#!/bin/bash
clear
configData=(`cat /usr/local/etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
currentDate=`date +"%Y-%m-%d"`
for userName in "${configData[@]}"
do
    expiredDate=$(grep -w "^### $userName" "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
    userExpiredDate=$(date -d "$expiredDate" +%s)
    systemDate=$(date -d "$currentDate" +%s)
    expiredUser=$(((userExpiredDate - systemDate) / 86400))

    if [[ "$expiredUser" -le "0" ]]; then
        sed -i "/^### $userName $expiredDate/,/^},{/d" /usr/local/etc/xray/config.json
        rm -f /usr/local/etc/xray/$userName.json
        rm -f /home/vmess/public_html/$userName.yaml
        systemctl restart xray.service
    fi
done