#!/bin/bash
clear
if [ "${EUID}" -ne 0 ]; then
		echo -e "${EROR} Please Run This Script As Root User !"
		exit 1
fi
xrayServer=127.0.0.1:10085
xrayLocation=/usr/local/bin/xray

xrayData () {
    $xrayLocation api statsquery --server=$xrayServer \
    | awk '{
        if (match($1, /"name":/)) {
            f=1; gsub(/"|,/, "", $2);
            split($2, p, ">>>");
            printf "%s:%s->%s\t", p[1],p[2],p[4];
        }
        else if (match($1, /"value":/) && f){
          f = 0;
          gsub(/"/, "", $2);
          printf "%.0f\n", $2;
        }
        else if (match($0, /}/) && f) { f = 0; print 0; }
    }'
}

userUsage() {
    local usageData="$1"
    local prefixData="$2"
    local sortedData=$(echo "$usageData" | grep "^${prefixData}" | sort -r | awk '{ gsub("user:", "") ; print $0 }' | awk '{ gsub("->downlink", "") ; print $0 }' | awk '{ gsub("->uplink", "") ; print $0 }' | awk '{ gsub("\t", " ") ; print $0 }' | awk '{a[$1]=a[$1] FS $2} END{for(i in a) print i a[i]}')
    local totalData=$(echo "$sortedData" | awk '{up+=$2}{dl+=$3}END{printf "\033[1;33mTotal\t%.0f\t%.0f", up, dl;}')
    local traficData=$(echo -e "${sortedData}\n${totalData}" | numfmt --field=2 --suffix=B --to=iec | numfmt --field=3 --suffix=B --to=iec)
    
    echo -e "\033[1;33mUser Upload Download\n\033[0m${traficData}" | column -t
}

usageData=$(xrayData $1)
echo -e "\033[0m——————————————————————————————————————"
echo -e "\033[0m         User Bandwidth Usage         "
echo -e "\033[0m——————————————————————————————————————"
userUsage "$usageData" "user"
echo ""
read -p "$(echo -e "\033[0mBack")"
menu
