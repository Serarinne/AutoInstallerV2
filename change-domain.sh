#!/bin/bash
clear
export serverIP=$(wget -qO- ipv4.icanhazip.com)

echo -e "——————————————————————————————————————"
echo -e "            Change Domain             "
echo -e "——————————————————————————————————————"
read -rp "New Domain: " serverDomain
rm -f /usr/local/etc/xray/ip
rm -f /usr/local/etc/xray/domain
echo $serverDomain > /usr/local/etc/xray/domain
echo $serverIP > /usr/local/etc/xray/ip
clear
sleep 1
systemctl stop nginx
sleep 1
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $serverDomain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $serverDomain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
sleep 1
systemctl restart nginx
clear
menu