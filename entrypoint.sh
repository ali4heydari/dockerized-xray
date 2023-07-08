#!/bin/sh


# cron job for getting geoip and geosite
#  https://newbedev.com/how-to-run-a-cron-job-inside-a-docker-container
#  At 04:00 on Tuesday. (https://crontab.guru/#0_4_*_*_2)
echo "Config cron job..."

echo "0 4 * * 2 echo /app/scheduled-job.sh >> /var/log/scheduled-job.log" >> /etc/crontabs/root
crond -l 2 -f > /dev/stdout 2> /dev/stderr &

# Run scheduled-job.sh for first time
echo "Run scheduled-job.sh for first time..."
sh /app/scheduled-job.sh


if [ -f /app/configs/config_info.txt ]; then
  echo "/app/configs/config.json already exists"
else
  IPV6=$(curl -6 -sSL --connect-timeout 3 --retry 2  ip.sb || echo "null")
  IPV4=$(curl -4 -sSL --connect-timeout 3 --retry 2  ip.sb || echo "null")
  if [ -z "$UUID" ]; then
    echo "UUID is not set, generate random UUID"
    UUID="$(xray uuid)"
    echo "UUID: $UUID"
  fi

  if [ -z "$EXTERNAL_PORT" ]; then
    echo "EXTERNAL_PORT is not set, use default value 443"
    EXTERNAL_PORT=443
  fi

  if [ -z "$DEST" ]; then
    echo "DEST is not set. default value www.apple.com:443"
    DEST="www.apple.com:443"
  fi

  if [ -z "$SERVERNAMES" ]; then
    echo "SERVERNAMES is not set. use default value [\"www.apple.com\",\"images.apple.com\"]"
    SERVERNAMES="www.apple.com images.apple.com"
  fi

  if [ -z "$PRIVATEKEY" ]; then
    echo "PRIVATEKEY is not set. generate new key"
    xray x25519 >/key
    PRIVATEKEY=$(cat /key | grep "Private" | awk -F ': ' '{print $2}')
    PUBLICKEY=$(cat /key | grep "Public" | awk -F ': ' '{print $2}')
    echo "Private key: $PRIVATEKEY"
    echo "Public key: $PUBLICKEY"
  fi

  if [ -z "$NETWORK" ]; then
    echo "NETWORK is not set, set default value tcp"
    NETWORK="tcp"
  fi
  # change config
  jq ".inbounds[0].settings.clients[0].id=\"$UUID\"" /app/configs/config.json >/app/configs/config.json_tmp && mv /app/configs/config.json_tmp /app/configs/config.json
  jq ".inbounds[0].streamSettings.realitySettings.dest=\"$DEST\"" /app/configs/config.json >/app/configs/config.json_tmp && mv /app/configs/config.json_tmp /app/configs/config.json

  SERVERNAMES_JSON_ARRAY="$(echo "[$(echo $SERVERNAMES | awk '{for(i=1;i<=NF;i++) printf "\"%s\",", $i}' | sed 's/,$//')]")"
  jq --argjson serverNames "$SERVERNAMES_JSON_ARRAY" '.inbounds[0].streamSettings.realitySettings.serverNames = $serverNames' /app/configs/config.json >/app/configs/config.json_tmp && mv /app/configs/config.json_tmp /app/configs/config.json

  jq ".inbounds[0].streamSettings.realitySettings.privateKey=\"$PRIVATEKEY\"" /app/configs/config.json >/app/configs/config.json_tmp && mv /app/configs/config.json_tmp /app/configs/config.json
  jq ".inbounds[0].streamSettings.network=\"$NETWORK\"" /app/configs/config.json >/app/configs/config.json_tmp && mv /app/configs/config.json_tmp /app/configs/config.json

  FIRST_SERVERNAME=$(echo $SERVERNAMES | awk '{print $1}')
  # config info with green color
  echo -e "\033[32m" >/app/configs/config_info.txt
  echo "IPV6: $IPV6" >>/app/configs/config_info.txt
  echo "IPV4: $IPV4" >>/app/configs/config_info.txt
  echo "UUID: $UUID" >>/app/configs/config_info.txt
  echo "DEST: $DEST" >>/app/configs/config_info.txt
  echo "PORT: $EXTERNAL_PORT" >>/app/configs/config_info.txt
  echo "SERVERNAMES: $SERVERNAMES (choose one)" >>/app/configs/config_info.txt
  echo "PRIVATEKEY: $PRIVATEKEY" >>/app/configs/config_info.txt
  echo "PUBLICKEY: $PUBLICKEY" >>/app/configs/config_info.txt
  echo "NETWORK: $NETWORK" >>/app/configs/config_info.txt
  if [ "$IPV4" != "null" ]; then
    SUB_IPV4="vless://$UUID@$IPV4:$EXTERNAL_PORT?encryption=none&security=reality&type=$NETWORK&sni=$FIRST_SERVERNAME&fp=chrome&pbk=$PUBLICKEY&flow=xtls-rprx-vision#wulabing_docker_vless_reality_vision"
    echo "IPV4 subscribe link: $SUB_IPV4" >>/config_info.txt
    echo -e "IPV4 subscribe QR code:\n$(echo "$SUB_IPV4" | qrencode -o - -t UTF8)" >>/app/configs/config_info.txt
  fi
  if [ "$IPV6" != "null" ];then
    SUB_IPV6="vless://$UUID@$IPV6:$EXTERNAL_PORT?encryption=none&security=reality&type=$NETWORK&sni=$FIRST_SERVERNAME&fp=chrome&pbk=$PUBLICKEY&flow=xtls-rprx-vision#wulabing_docker_vless_reality_vision"
    echo "IPV6 subscribe link: $SUB_IPV6" >>/config_info.txt
    echo -e "IPV6 subscribe QR code:\n$(echo "$SUB_IPV6" | qrencode -o - -t UTF8)" >>/app/configs/config_info.txt
  fi


  echo -e "\033[0m" >>/app/configs/config_info.txt

fi


# show config info
cat /app/configs/config_info.txt

# run xray
xray -config /app/configs/config.json
