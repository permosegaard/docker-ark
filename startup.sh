#!/bin/bash

if [ -f /.pause ]; then read -p "pausing..."; fi

STEAM_APP_ID=376030

ip route change default via 172.17.42.254
if [ -z "${STEAM_USER}" ]; then STEAM_CREDENTIALS="anonymous"; else STEAM_CREDENTIALS="${STEAM_USERNAME} ${STEAM_PASSWORD}"; fi

if [ -f /seed/${CONTAINER_TYPE}/seed ]
then
  tar -cf /overlay/root.tar /root && mkdir /root/steamcmd && curl -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -vzx -C "/root/steamcmd/"
  while [ "$( find /server/ -type f | wc -l )" -lt 1 ]; do /root/steamcmd/steamcmd.sh +login ${STEAM_CREDENTIALS} +force_install_dir /server +app_update ${STEAM_APP_ID} validate +quit; done
  tar -cf /overlay/server.tar /server && tar -cf /overlay/root-steamcmd.tar /root/steamcmd && tar -cf /overlay/root-steam.tar /root/Steam && echo "seed generation complete, pausing..." && read && exit
else
  if [ ! -f /overlay/.provisioned ]; then mkdir -p /overlay/{root,server,root-steamcmd,root-steam} /server/ && touch /overlay/.provisioned; fi
  mount -t aufs -o noxino -o br=/overlay/root=rw:/seed/${CONTAINER_TYPE}/root=ro none /root
  mount -t aufs -o noxino -o br=/overlay/server=rw:/seed/${CONTAINER_TYPE}/game=ro none /server
  mkdir -p /root/steamcmd && mount -t aufs -o noxino -o br=/overlay/root-steamcmd=rw:/seed/${CONTAINER_TYPE}/root-steamcmd=ro none /root/steamcmd
  mkdir -p /root/Steam && mount -t aufs -o noxino -o br=/overlay/root-steam=rw:/seed/${CONTAINER_TYPE}/root-steam=ro none /root/Steam
  
  /root/steamcmd/steamcmd.sh +login ${STEAM_CREDENTIALS} +force_install_dir /server +app_update ${STEAM_APP_ID} validate +quit
  
  if [ ! -f /server/server.cfg ]
  then
    cat << EOF > /server/server.cfg
SessionName=${CONTAINER_NAME}
Port=${PORT_7778}
QueryPort=${PORT_27016}
RCONEnabled=True
RCONPort=${PORT_32330}
ServerAdminPassword=
PreventOfflinePvP=True
PreventDiseases=True
EOF
  fi
  
  settings_string="TheIsland"; while read line; do settings_string+="?${line}"; done < /server/server.cfg
  
  ulimit -n 2048 && cd /server/ && ShooterGame/Binaries/Linux/ShooterGameServer ${settings_string} -server -log -UseBattlEye -usecache
fi
