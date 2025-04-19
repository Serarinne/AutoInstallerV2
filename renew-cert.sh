#!/bin/bash
clear
serverDomain=$(cat /usr/local/etc/xray/domain)
clear
echo -e "Renewing certificate...." 
sleep 0.5
systemctl stop nginx
sleep 1
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $serverDomain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $serverDomain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
sleep 1
systemctl restart nginx
echo "Certificate update complete"
echo ""
read -p "$(echo -e "Back")"
menu