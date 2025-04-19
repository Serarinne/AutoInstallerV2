#!/bin/bash
clear
if [ "${EUID}" -ne 0 ]; then
	echo -e "${EROR} Please Run This Script As Root User !"
	exit 1
fi

echo -e ""
echo -e "——————————————————————————————————————"
echo -e "         Check System Bandwidth       "
echo -e "——————————————————————————————————————"
echo -e ""
echo -e " 1   Hourly Usage"
echo -e " 2   Daily Usage"
echo -e " 3   Monthly Usage"
echo -e " 4   Current Usage"
echo -e " 0   Menu"
echo -e ""
echo -e "——————————————————————————————————————"
read -p " Select From Options [1-5] :  " options

case $options in
1)
clear
echo -e "——————————————————————————————————————"
echo -e "        Hourly Bandwidth Usage        "
echo -e "——————————————————————————————————————"
echo -e ""
vnstat -h
echo -e ""
echo -e "——————————————————————————————————————"
;;

2)
clear
echo -e "——————————————————————————————————————"
echo -e "         Daily Bandwidth Usage        "
echo -e "——————————————————————————————————————"
echo -e ""
vnstat -d
echo -e ""
echo -e "——————————————————————————————————————"
;;

3)
clear
echo -e "——————————————————————————————————————"
echo -e "        Monthly Bandwidth Usage       "
echo -e "——————————————————————————————————————"
echo -e ""
vnstat -m
echo -e ""
echo -e "——————————————————————————————————————"
;;

4)
clear
echo -e "——————————————————————————————————————"
echo -e "        Current Bandwidth Usage       "
echo -e "——————————————————————————————————————"
echo -e ""
vnstat -l
echo -e ""
echo -e "——————————————————————————————————————"
;;

0)
menu
;;

*)
echo -e "Incorrect Number!"
;;
esac
read -p "$(echo -e "Back")"
system-bandwidth