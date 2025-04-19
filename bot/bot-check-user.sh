#!/bin/bash
totalUser=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
echo -e "Total: ${totalUser}"
grep -E "^### " "/usr/local/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '