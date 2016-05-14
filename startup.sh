#!/bin/bash

ip route change default via 172.17.42.254

ulimit -n 2048

/root/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server +app_update 376030 +quit

settings_array=(
	"SessionName=${CONTAINER_NAME}"
	"Port=${PORT_7778}"
	"QueryPort=${PORT_27016}"
	"RCONEnabled=True"
	"RCONPort=${PORT_32330}"
)
settings_string="$( printf "?%s" "${settings_array[@]}" )"

cd /server/ && ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?${settings_string} -server -log
