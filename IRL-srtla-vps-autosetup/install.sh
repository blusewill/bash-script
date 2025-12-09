#!/bin/sh

current_directory=$PWD

if ! command -v docker >/dev/null 2>&1; then
  printf "Can't Find Docker. Auto Installing..."
  docker_installed=0
else
  printf "Docker has been installed on this Device!\n"
  printf "Setting up srtla Server..."
  docker_installed=1
fi

if [ $docker_installed = 0 ]; then
  curl -fsSL https://get.docker.com -o $current_directory/install-docker.sh
  chmod +x $current_directory/install-docker.sh

  sudo sh $current_directory/install-docker.sh
fi

printf "Please type your belabox username :"

read -r "belabox_username"

printf "\n Please type your belabox password : "

# Read Password Sliently
stty -echo
read -r "belabox_password"
stty echo

curl -fsSL https://raw.githubusercontent.com/blusewill/bash-script/refs/heads/main/IRL-srtla-vps-autosetup/config.json -o config.json

sed -i -e "s/belabox-user/$belabox_username" "$current_directory/config.json"

sed -i -e "s/belabox-pass/$belabox_password" "$current_directory/config.json"

docker run -d --name belabox-receiver -p 5000:5000/udp -p 8181:8181/tcp -p 8282:8282/udp -p 3000:3000/tcp -v $current_directory/config.json:/app/config.json datagutt/belabox-receiver:latest

prinrtf "Now System will restart in 10 seconds..."
sleep 10

systemctl restart
