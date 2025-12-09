#!/bin/sh

printf "HI! $USER\n"
printf "For some cases we might need your Account Password.\n"
printf "Plaese Insert your account password "

read -s -r "account_password"

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

  echo $account_password | sh $current_directory/install-docker.sh
fi

docker run -d --name belabox-receiver -p 5000:5000/udp -p 8181:8181/tcp -p 8282:8282/udp -p 3000:3000/tcp -v ./config.json:/app/config.json datagutt/belabox-receiver:latest

prinrtf "Now System will restart in 10 seconds..."
sleep 10

systemctl restart
