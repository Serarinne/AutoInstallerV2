#!/bin/bash
timedatectl set-timezone Asia/Jakarta
clear
if [ -f "/usr/local/etc/xray/domain" ]; then
    echo "Script sudah diinstall"
    exit 0
fi
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
cat > /etc/systemd/resolved.conf <<-END
[Resolve]
DNS=1.1.1.1
DNS=1.0.0.1
END

systemctl restart systemd-resolved.service
export scriptURL="https://raw.githubusercontent.com/Serarinne/AutoInstallerV2/main"
export serverIP=$(wget -qO- ipv4.icanhazip.com)

clear
echo -e "Instalasi Package..."
apt remove --purge ufw firewalld exim4 -y
apt install git curl wget nano lsof fail2ban netfilter-persistent bzip2 gzip coreutils rsyslog iftop htop zip unzip net-tools sed screen gnupg gnupg1 gnupg2 bc apt-transport-https build-essential dirmngr libxml-parser-perl neofetch libsqlite3-dev socat python3 xz-utils dnsutils lsb-release cron bash-completion ntpdate chrony pwgen openssl netcat vnstat -y

ntpdate pool.ntp.org
timedatectl set-ntp true
systemctl enable chrony && systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
date

apt install nginx -y
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "${scriptURL}/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "${scriptURL}/vps.conf"
mkdir -p /home/vmess/public_html
chown -R www-data:www-data /home/vmess/public_html
systemctl restart nginx

bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
clear
read -rp "Server Name : " serverName
echo $serverName > /usr/local/etc/xray/name
read -rp "Domain : " serverDomain
echo $serverDomain > /usr/local/etc/xray/domain
echo $serverIP >> /usr/local/etc/xray/ip

mkdir /root/.acme.sh
curl ${scriptURL}/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d ${serverDomain} --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d ${serverDomain} --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc

curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
apt update
apt install cloudflare-warp -y
clear
warp-cli registration new
warp-cli mode proxy
warp-cli proxy port 10086
warp-cli connect

cat > /etc/nginx/conf.d/xray.conf <<EOF
server {
  listen 80;
  listen [::]:80;
  listen 443 ssl http2 reuseport;
  listen [::]:443 http2 reuseport;
  server_name 127.0.0.1 localhost;
  ssl_certificate /usr/local/etc/xray/xray.crt;
  ssl_certificate_key /usr/local/etc/xray/xray.key;
  ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  root /usr/share/nginx/html;
  
  location / {
    if (\$http_upgrade != "Upgrade") {
      rewrite /(.*) /vmess break;
    }
    
    proxy_redirect off;
    proxy_pass http://127.0.0.1:23456;
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$http_host;
  }
  
  location = /vmess {
    proxy_redirect off;
    proxy_pass http://127.0.0.1:23456;
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$http_host;
  }
}
EOF

cat > /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": "23456",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "60d9785f-0e59-4988-aee1-322351b4de7f",
            "alterId": 0,
            "level": 0,
            "email": "Admin"
#VMESS
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess",
          "host": ""
        },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "127.0.0.1",
            "port": 10086
          }
        ]
      },
      "tag": "warp"
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "warp",
        "domain": [
          "keyword:a",
          "keyword:i",
          "keyword:u",
          "keyword:e",
          "keyword:o"
        ]
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      },
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

systemctl daemon-reload
systemctl enable xray.service
systemctl restart xray.service
systemctl restart nginx
systemctl restart vnstat

sleep 2

clear
echo -e "Instalasi Addon..."
cd /usr/local/sbin
wget -O menu "${scriptURL}/menu.sh" && chmod +x menu
wget -O change-domain "${scriptURL}/change-domain.sh" && chmod +x change-domain
wget -O restart-service "${scriptURL}/restart-service.sh" && chmod +x restart-service
wget -O auto-delete-expired-user "${scriptURL}/auto-delete-expired-user.sh" && chmod +x auto-delete-expired-user
wget -O auto-delete-log "${scriptURL}/auto-delete-log.sh" && chmod +x auto-delete-log
wget -O renew-cert "${scriptURL}/renew-cert.sh" && chmod +x renew-cert

cd /usr/bin
wget -O add-user "${scriptURL}/add-user.sh" && chmod +x add-user
wget -O check-user-login "${scriptURL}/check-user-login.sh" && chmod +x check-user-login
wget -O delete-user "${scriptURL}/delete-user.sh" && chmod +x delete-user
wget -O extend-user "${scriptURL}/extend-user.sh" && chmod +x extend-user
wget -O check-user-config "${scriptURL}/check-user-config.sh" && chmod +x check-user-config
wget -O user-bandwidth "${scriptURL}/user-bandwidth.sh" && chmod +x user-bandwidth
wget -O system-bandwidth "${scriptURL}/system-bandwidth.sh" && chmod +x system-bandwidth
wget -O backup-server "${scriptURL}/backup-server.sh" && chmod +x /usr/bin/backup-server
wget -O restore-server "${scriptURL}/restore-server.sh" && chmod +x /usr/bin/restore-server

echo "0 2 * * * root auto-delete-expired-user" >> /etc/crontab
echo "0 3 * * * root backup-server" >> /etc/crontab
echo "0 */2 * * * root auto-delete-log" >> /etc/crontab

apt autoclean -y
echo "menu" >> /root/.profile
service cron restart > /dev/null 2>&1
rm /root/install.sh
reboot
