#!/bin/bash
clear
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi

export scriptURL="https://raw.githubusercontent.com/Serarinne/AutoInstallerV2/main/bot"

mkdir /root/.bot
cd /root/.bot
wget ${scriptURL}/index.py && chmod +x index.py
wget ${scriptURL}/requirements.txt && chmod +x requirements.txt
wget ${scriptURL}/.env && chmod +x .env

cd /usr/bin
wget -O bot-add-user "${scriptURL}/bot-add-user.sh" && chmod +x bot-add-user
wget -O bot-check-user "${scriptURL}/bot-check-user.sh" && chmod +x bot-check-user
wget -O bot-total-user "${scriptURL}/bot-total-user.sh" && chmod +x bot-total-user

apt install python3-pip
pip install Flask
pip install requests
pip install jsonify
pip install requests-toolbelt
pip install python-dotenv
pip install spur

cat > /etc/systemd/system/panelbot.service <<-END
[Unit]
Description=Bot Whatsapp

[Service]
ExecStart=nohup python3 /root/.bot/index.py &
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
END

chmod +x /etc/systemd/system/panelbot.service
cd /etc/systemd/system
systemctl enable panelbot.service
systemctl start panelbot.service
systemctl restart panelbot.service
rm -f /root/install.sh