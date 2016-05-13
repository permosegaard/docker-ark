#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Europe/London" > /etc/timezone && dpkg-reconfigure tzdata
apt-get update && apt-get install -qy iproute2 

apt-get install -qy apt-utils ca-certificates lib32gcc1 net-tools lib32stdc++6 lib32z1 lib32z1-dev curl

mkdir -p /root/steamcmd /server

curl -s "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -vzx -C "/root/steamcmd/"

/root/steamcmd/steamcmd.sh +login anonymous +force_install_dir /server +app_update 376030 +quit

apt-get clean && rm -Rf /var/lib/apt/lists/*
