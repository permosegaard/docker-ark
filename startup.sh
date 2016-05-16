#!/bin/bash

ip route change default via 172.17.42.254

ulimit -n 2048

if [ "$( find /server/ -type f | wc -l )" -lt "1" ]; then echo "copying seed across... this may take some time depending on the game size"; time cp -Rs /seed/${CONTAINER_TYPE}/ /server/; fi
/root/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server +app_update 376030 validate +quit

settings_array=(
	"SessionName=${CONTAINER_NAME}"
	"Port=${PORT_7778}"
	"QueryPort=${PORT_27016}"
	"RCONEnabled=True"
	"RCONPort=${PORT_32330}"
)
settings_string="$( printf "?%s" "${settings_array[@]}" )"

cd /server/ && ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?${settings_string} -server -log
