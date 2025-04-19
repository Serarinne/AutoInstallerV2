#!/bin/bash
clear
echo -n > /tmp/other.txt
systemLog=(`cat /usr/local/etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
echo -e "——————————————————————————————————————"
echo -e "              USER LOGIN              "
echo -e "——————————————————————————————————————"
for userAccount in "${systemLog[@]}"
do
if [[ -z "$userAccount" ]]; then
userAccount="Admin"
fi
echo -n > /tmp/clientIp.txt
userLog=(`cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${userLog[@]}"
do
ipList=$(cat /var/log/xray/access.log | grep -w "$userAccount" | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$ipList" = "$ip" ]]; then
echo "$ipList" >> /tmp/clientIp.txt
else
echo "$ip" >> /tmp/other.txt
fi
ipUser=$(cat /tmp/clientIp.txt)
sed -i "/$ipUser/d" /tmp/other.txt > /dev/null 2>&1
done
ipList=$(cat /tmp/clientIp.txt)
if [[ -z "$ipList" ]]; then
echo > /dev/null
else
ipUser=$(cat /tmp/clientIp.txt | nl)
echo "User : $userAccount";
echo "$ipUser";
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fi
rm -rf /tmp/clientIp.txt
rm -rf /tmp/other.txt
done
echo ""
echo ""
read -p "$( echo -e "Back") "
menu
