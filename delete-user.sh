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
echo -e "              Delete User             "
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

userName=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${userNumber}"p)
expiredDate=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${userNumber}"p)
sed -i "/^### $userName $expiredDate/,/^},{/d" /usr/local/etc/xray/config.json
rm -f /usr/local/etc/xray/$userName.json
rm -f /home/vmess/public_html/$userName.yaml
systemctl restart xray.service
clear
echo -e ""
echo "Username: $userName has been deleted"
echo ""
read -p "$(echo -e "Back")"
menu
