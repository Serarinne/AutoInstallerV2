#!/bin/bash
totalUser=$(grep -c -E "^### " "/usr/local/etc/xray/config.json")
echo -e "${totalUser}"
