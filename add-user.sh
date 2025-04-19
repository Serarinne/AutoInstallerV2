#!/bin/bash
clear
serverDomain=$(cat /usr/local/etc/xray/domain)
serverName=$(cat /usr/local/etc/xray/name)
serverIP=$(cat /usr/local/etc/xray/ip)

echo -e "——————————————————————————————————————"
echo -e "               Add User               "
echo -e "——————————————————————————————————————"
until [[ $userName =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
  read -rp "Username : " -e userName
  CLIENT_EXISTS=$(grep -w $userName /usr/local/etc/xray/config.json | wc -l)
  if [[ ${CLIENT_EXISTS} == '1' ]]; then
    clear
    echo ""
    echo "Username already used"
    echo ""
    echo -e "═══════════════════"
    read -n 1 -s -r -p "Back"
    menu
  fi
done

activePeriode=30
userId=$(cat /proc/sys/kernel/random/uuid)
expiredDate=`date -d "$activePeriode days" +"%Y-%m-%d"`
sed -i '/#VMESS$/a\### '"$userName $expiredDate"'\
},{"id": "'""$userId""'","level": '"0"',"alterId": '"0"',"email": "'""$userName""'"' /usr/local/etc/xray/config.json

cat> /usr/local/etc/xray/$userName.json << EOF
      {
      "v": "2",
      "ps": "${serverName} ${userName} ${expiredDate}",
      "add": "${serverDomain}",
      "port": "80",
      "id": "${userId}",
      "aid": "0",
      "net": "ws",
      "path": "/vmess",
      "type": "none",
      "host": "${serverDomain}",
      "tls": "none"
}
EOF

cat > /home/vmess/public_html/$userName.yaml <<EOF
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
tproxy-port: 7895
ipv6: false
mode: rule
log-level: silent
allow-lan: true
external-controller: 0.0.0.0:9090
secret: ""
bind-address: "*"
unified-delay: true
profile:
  store-selected: true
  store-fake-ip: true
dns:
  enable: true
  ipv6: false
  use-host: true
  enhanced-mode: fake-ip
  listen: 0.0.0.0:7874
  nameserver:
    - 8.8.8.8
    - 1.1.1.1
    - https://dns.google/dns-query
  fallback:
    - 1.0.0.1
    - 8.8.4.4
    - https://cloudflare-dns.com/dns-query
    - 112.215.203.254
  default-nameserver:
    - 8.8.8.8
    - 1.1.1.1
    - 112.215.203.254
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - "*.lan"
    - "*.localdomain"
    - "*.example"
    - "*.invalid"
    - "*.localhost"
    - "*.test"
    - "*.local"
    - "*.home.arpa"
    - time.*.com
    - time.*.gov
    - time.*.edu.cn
    - time.*.apple.com
    - time1.*.com
    - time2.*.com
    - time3.*.com
    - time4.*.com
    - time5.*.com
    - time6.*.com
    - time7.*.com
    - ntp.*.com
    - ntp1.*.com
    - ntp2.*.com
    - ntp3.*.com
    - ntp4.*.com
    - ntp5.*.com
    - ntp6.*.com
    - ntp7.*.com
    - "*.time.edu.cn"
    - "*.ntp.org.cn"
    - +.pool.ntp.org
    - time1.cloud.tencent.com
    - music.163.com
    - "*.music.163.com"
    - "*.126.net"
    - musicapi.taihe.com
    - music.taihe.com
    - songsearch.kugou.com
    - trackercdn.kugou.com
    - "*.kuwo.cn"
    - api-jooxtt.sanook.com
    - api.joox.com
    - joox.com
    - y.qq.com
    - "*.y.qq.com"
    - streamoc.music.tc.qq.com
    - mobileoc.music.tc.qq.com
    - isure.stream.qqmusic.qq.com
    - dl.stream.qqmusic.qq.com
    - aqqmusic.tc.qq.com
    - amobile.music.tc.qq.com
    - "*.xiami.com"
    - "*.music.migu.cn"
    - music.migu.cn
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    - msftconnecttest.com
    - msftncsi.com
    - localhost.ptlogin2.qq.com
    - localhost.sec.qq.com
    - +.srv.nintendo.net
    - +.stun.playstation.net
    - xbox.*.microsoft.com
    - xnotify.xboxlive.com
    - +.battlenet.com.cn
    - +.wotgame.cn
    - +.wggames.cn
    - +.wowsgame.cn
    - +.wargaming.net
    - proxy.golang.org
    - stun.*.*
    - stun.*.*.*
    - +.stun.*.*
    - +.stun.*.*.*
    - +.stun.*.*.*.*
    - heartbeat.belkin.com
    - "*.linksys.com"
    - "*.linksyssmartwifi.com"
    - "*.router.asus.com"
    - mesu.apple.com
    - swscan.apple.com
    - swquery.apple.com
    - swdownload.apple.com
    - swcdn.apple.com
    - swdist.apple.com
    - lens.l.google.com
    - stun.l.google.com
    - +.nflxvideo.net
    - "*.square-enix.com"
    - "*.finalfantasyxiv.com"
    - "*.ffxiv.com"
    - "*.mcdn.bilivideo.cn"
    - +.media.dssott.com
proxies:
  - name: ${serverName} ${userName} ${expiredDate}
    server: ${serverDomain}
    port: 80
    type: vmess
    uuid: ${userId}
    alterId: 0
    cipher: auto
    tls: false
    skip-cert-verify: true
    servername: ${serverDomain}
    network: ws
    ws-opts:
      path: /vmess
      headers:
        Host: ${serverDomain}
    udp: true
proxy-groups:
  - name: XRAY-Server
    type: select
    proxies:
      - ${serverName} ${userName} ${expiredDate}
      - DIRECT
rules:
  - MATCH,XRAY-Server
EOF

vmessUrl="vmess://$(base64 -w 0 /usr/local/etc/xray/$userName.json)"
systemctl restart xray.service
service cron restart

clear
echo -e ""
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
read -p "$(echo -e "Back")"
menu
