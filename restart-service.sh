#!/bin/bash
clear
echo -e ""
echo -e "Restart Cron"
systemctl restart cron.service
echo -e "Restart Nginx"
systemctl restart nginx.service
echo -e "Restart Vmess"
systemctl restart xray.service
echo -e ""
read -p "$(echo -e "Back")"
menu
