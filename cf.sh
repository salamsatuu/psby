#!/bin/bash
MYIP=$(wget -qO- icanhazip.com);
apt install jq curl -y
clear
echo -e ""
echo -e "\033[96;1m============================\033[0m"
echo -e "\033[93;1m      MEMBUAT DOMAIN RANDOM"
echo -e "\033[96;1m============================\033[0m"
echo -e ""
sub=$(</dev/urandom tr -dc a-z0-9 | head -c5)
DOMAIN=macro.my.id
SUB_DOMAIN=${sub}.macro.my.id
CF_ID=Sanztunneling@gmail.com
CF_KEY=9a69eca3f44c5d60c0f0db9a307edec84527b
set -euo pipefail
IP=$(curl -sS ifconfig.me);
echo "Updating DNS for ${SUB_DOMAIN}..."
ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
     RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
     -H "X-Auth-Email: ${CF_ID}" \
     -H "X-Auth-Key: ${CF_KEY}" \
     -H "Content-Type: application/json" \
     --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')
     
echo "Host : $SUB_DOMAIN"
	echo "$SUB_DOMAIN" > /etc/xray/domain
echo "IP=$SUB_DOMAIN" > /var/lib/kyt/ipvps.conf
cd
