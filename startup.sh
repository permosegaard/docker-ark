#!/bin/bash

ip route change default via 172.17.42.254
if [ -z "${STEAM_USER}" ]; then STEAM_CREDENTIALS="anonymous"; else STEAM_CREDENTIALS="${STEAM_USERNAME} ${STEAM_PASSWORD}"; fi

# start seed update section
# shell in and rsync /server/* and /root/{Steam,steamcmd}/* to host /seed/$type/{game,steam,steamcmd}
curl -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -vzx -C "/root/steamcmd/"
/root/steamcmd/steamcmd.sh +login $STEAM_CREDENTIALS +force_install_dir /server +app_update 376030 +quit
apt-get update && apt-get install -y rsync openssh-client && echo && echo "update complete, pausing..." && read && exit
# end seed update section

if [ "$( find /server/ -type f | wc -l )" -lt "1" ]
then
  echo "copying seed across... this may take some time depending on the game size"
  rm -Rf /server/* /root/Steam/* /root/steamcmd/*
  cp -Rf /seed/${CONTAINER_TYPE}/game/* /server/ # change to hard/soft links
  cp -Rf /seed/${CONTAINER_TYPE}/steamcmd/* /root/steamcmd/ # change to hard/soft links
  cp -Rf /seed/${CONTAINER_TYPE}/steam/* /root/Steam/ # change to hard/soft links
fi

root/steamcmd/steamcmd.sh +login $STEAM_CREDENTIALS +force_install_dir /server +app_update 376030 validate +quit

settings_array=(
	"SessionName=${CONTAINER_NAME}"
	"Port=${PORT_7778}"
	"QueryPort=${PORT_27016}"
	"RCONEnabled=True"
	"RCONPort=${PORT_32330}"
)
settings_string="$( printf "?%s" "${settings_array[@]}" )"

ulimit -n 2048 && cd /server/ && ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?${settings_string} -server -log
