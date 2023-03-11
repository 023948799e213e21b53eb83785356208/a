#!/bin/bash

sudo apt-get update
sudo apt-get install -y openvpn easy-rsa

make-cadir ~/openvpn-ca
cd ~/openvpn-ca

source vars
./clean-all
./build-ca --batch
./build-key-server --batch server
./build-dh
openvpn --genkey --secret keys/ta.key

mkdir ~/client-configs
chmod 700 ~/client-configs

cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gunzip /etc/openvpn/server.conf.gz

sed -i 's/;tls-auth ta.key 0/tls-auth ta.key 0/' /etc/openvpn/server.conf
sed -i 's/;cipher AES-256-CBC/cipher AES-256-CBC\nauth SHA256/' /etc/openvpn/server.conf
sed -i 's/;user nobody/user nobody/' /etc/openvpn/server.conf
sed -i 's/;group nogroup/group nogroup/' /etc/openvpn/server.conf
sed -i 's/ca ca.crt/#ca ca.crt/' /etc/openvpn/server.conf
sed -i 's/cert server.crt/#cert server.crt/' /etc/openvpn/server.conf
sed -i 's/key server.key/#key server.key/' /etc/openvpn/server.conf

echo 'ca /etc/openvpn/easy-rsa/keys/ca.crt' >> /etc/openvpn/server.conf
echo 'cert /etc/openvpn/easy-rsa/keys/server.crt' >> /etc/openvpn/server.conf
echo 'key /etc/openvpn/easy-rsa/keys/server.key' >> /etc/openvpn/server.conf
echo 'dh /etc/openvpn/easy-rsa/keys/dh2048.pem' >> /etc/openvpn/server.conf
echo 'tls-auth /etc/openvpn/easy-rsa/keys/ta.key 0' >> /etc/openvpn/server.conf

systemctl start openvpn@server
systemctl enable openvpn@server

echo "test vpn"
