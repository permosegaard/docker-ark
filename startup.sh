#!/bin/bash

ip route change default via 172.17.42.254

settings_array=(
	"Port=${PORT_7778}"
	"QueryPort=${PORT_27016}"
	"RCONEnabled=True"
	"RCONPort=${PORT_32330}"
)
settings_string="$( printf "?%s" "${settings_array[@]}" )"

cd /server/ && ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?${settings_string} -server -log
