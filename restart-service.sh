#!/bin/bash
clear
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    ([[ -e $HOME/fim ]] && rm $HOME/fim ${CMD[0]} -y >/dev/null 2>&1 ${CMD[1]} -y >/dev/null 2>&1 touch $HOME/fim) >/dev/null 2>&1 & tput civis
    echo -ne "Restarting Service..."
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e " "
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "Restarting..."
    done
    echo -e " [OK]"
    tput cnorm
}
restartCron() {
    systemctl restart cron.service
}
restartNginx() {
    systemctl restart nginx.service
}
restartXray() {
    systemctl restart xray.service
}

clear
echo -e ""
echo -e "Restart Cron"
fun_bar 'restartCron'
echo -e "Restart Nginx"
fun_bar 'restartNginx'
echo -e "Restart Vmess"
fun_bar 'restartXray'
echo -e ""
read -p "$(echo -e "Back")"
menu