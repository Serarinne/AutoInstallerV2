#!/bin/bash
clear
totalUptime="$(uptime -p | cut -d " " -f 2-10)"
cpuUsage=$(printf '%-3s' "$(top -bn1 | awk '/Cpu/ { cpu = "" 100 - $8 "%" }; END { print cpu }')")
ramUsage="$(free -m | awk 'NR==2 {print $3}') MB / $(free -m | awk 'NR==2 {print $2}') MB"
serviceStatus="$(systemctl is-active --quiet nginx && echo "NGINX") $(systemctl is-active --quiet xray && echo "- XRAY") $(systemctl is-active --quiet panelbot && echo "- BOT")"
totalUser=$(grep -c -E "^### $user" "/usr/local/etc/xray/config.json")
todayUsage=$(vnstat -d --oneline | awk -F\; '{print $6}' | sed 's/ //')
monthUsage=$(vnstat -m --oneline | awk -F\; '{print $11}' | sed 's/ //')

clear
echo ""
echo -e "————————————————————————————————————————————————————————"
echo -e "                     Control Panel                      "
echo -e "————————————————————————————————————————————————————————"
echo -e "  Server Name  :  $(cat /usr/local/etc/xray/name)  "
echo -e "  Domain       :  $(cat /usr/local/etc/xray/domain)  "
echo -e "  IP           :  $(cat /usr/local/etc/xray/ip)  "
echo -e "  Uptime       :  $totalUptime  "
echo -e "  CPU Usage    :  $cpuUsage  "
echo -e "  RAM Usage    :  $ramUsage  "
echo -e "  Service      :  $serviceStatus"
echo -e "————————————————————————————————————————————————————————"
echo -e "                  Total User : ${totalUser}             "
echo -e "————————————————————————————————————————————————————————"
echo -e "  1   Add User                4   Check Login"
echo -e "  2   Delete User             5   Check User Config"
echo -e "  3   Extend User             6   Check User Bandwidth"
echo -e ""
echo -e "  7   Change Domain           9   Check System Bandwith"
echo -e "  8   Renew Certificate       10  Restart Service"
echo -e ""
echo -e "  11  Backup                  13  Update XRay Core"
echo -e "  12  Restore                 14  Reboot Server"
echo -e "————————————————————————————————————————————————————————"
echo -e "  Today's Usage        : $todayUsage "
echo -e "  This Month's Usage   : $monthUsage "
echo -e "————————————————————————————————————————————————————————"
echo ""
read -p "  Select From Options [1-14] : " options
case $options in
1) add-user;;
2) delete-user;;
3) extend-user;;
4) check-user-login;;
5) check-user-config;;
6) user-bandwidth;;
7) change-domain;;
8) renew-cert;;
9) system-bandwidth;;
10) restart-service;;
11) backup-server;;
12) restore-server;;
13) clear; bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install;;
14) reboot;;
*) clear; menu;;
esac
