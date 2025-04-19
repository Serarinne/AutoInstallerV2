#!/bin/bash
clear
totalUser=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
if [[ ${totalUser} == '0' ]]; then
	echo ""
	echo "No user"
	echo ""
	exit 1
fi

echo -e "——————————————————————————————————————"
echo -e "             Extend User              "
echo -e "——————————————————————————————————————"
echo "No\tUser\tExpired"
grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ')'
until [[ ${userNumber} -ge 1 && ${userNumber} -le ${totalUser} ]]; do
	if [[ ${userNumber} == '1' ]]; then
		read -rp "User number [1]: " userNumber
	else
		read -rp "User number [1-${totalUser}]: " userNumber
	fi
done

read -p "Days: " activePeriode
userName=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${userNumber}"p)
expiredDate=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${userNumber}"p)
currentDate=$(date +%Y-%m-%d)
userExpiredDate=$(date -d "$expiredDate" +%s)
systemDate=$(date -d "$currentDate" +%s)
oldExpiredDate=$(((userExpiredDate - systemDate) / 86400))
newDate=$(($oldExpiredDate + $activePeriode))
newExpiredDate=`date -d "$newDate days" +"%Y-%m-%d"`
sed -i "s/### $userName $expiredDate/### $userName $newExpiredDate/g" /usr/local/etc/xray/config.json
systemctl restart xray.service
service cron restart
clear
echo ""
echo "The active period of the username $userName has been extended until $newExpiredDate"
echo ""
read -p "$(echo -e "Back")"
menu
