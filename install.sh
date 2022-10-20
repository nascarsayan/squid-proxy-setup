#!/usr/bin/env bash
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common apache2-utils squid -y
CN="proxy-ca"
openssl genrsa -out ./files/proxy-ca.key 4096
openssl req -x509 -new -nodes -key ./files/proxy-ca.key -sha256 -subj "/C=US/ST=CA/CN=$CN" -days 1024 -out ./files/proxy-ca.crt
htpasswd -c ./files/usercreds "$USER"
sudo cp ./files/proxy-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
mkdir -p /etc/squid
sudo cp -r ./files /etc/squid/
sudo cp ./files/squid.conf /etc/squid/squid.conf
perl -i -pe "s~/files/usercreds~/etc/squid/files/usercreds~g" /etc/squid/squid.conf
sudo systemctl restart squid
sudo systemctl enable squid
