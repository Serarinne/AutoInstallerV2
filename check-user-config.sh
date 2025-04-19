#!/bin/bash
clear
serverDomain=$(cat /usr/local/etc/xray/domain)
serverIP=$(cat /usr/local/etc/xray/ip)

totalUser=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
if [[ ${totalUser} == '0' ]]; then
    echo "No user"
    clear
    exit 1
fi

echo -e "——————————————————————————————————————"
echo -e "             Check User               "
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
userId=$(grep "},{" /usr/local/etc/xray/config.json | cut -b 11-46 | sed -n "${userNumber}"p)
expiredDate=$(grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${userNumber}"p)
vmessUrl="vmess://$(base64 -w 0 /usr/local/etc/xray/$userName.json)"

clear
echo -e ""
echo -e "═══[XRAY VMESS WS]════"
echo -e "Remarks           : ${userName}"
echo -e "Domain            : ${serverDomain}"
echo -e "IP/Host           : ${serverIP}"
echo -e "Port TLS          : 443"
echo -e "Port None TLS     : 80"
echo -e "ID                : ${userId}"
echo -e "AlterId           : 0"
echo -e "Security          : Auto"
echo -e "Network           : WS"
echo -e "Path              : /vmess"
echo -e "═══════════════════"
echo -e "VMESS URL         : ${vmessUrl}"
echo -e "═══════════════════"
echo -e "Expired Date      : $expiredDate"
echo -e "═══════════════════"
echo -e ""
echo ""
read -p "$( echo -e "Back") "
menu