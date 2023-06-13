#!/bin/bash

netconfIpMask=A
netconfGateway=A
netconfDns=A

read -p "IP-address/subnet mask: " netconfIpMask
read -p "Gateway: " netconfGateway
read -p "DNS Servers: " netconfDns

sed -i -e 's/dhcp4: yes/dhcp4: no/' 01-netcfg.yaml

sed -i -e "8a\      addresses: [$netconfIpMask]"  01-netcfg.yaml
sed -i -e "9a\      gateway4: $netconfGateway"  01-netcfg.yaml
sed -i -e "10a\      nameservers:"  01-netcfg.yaml
sed -i -e "11a\        addresses: [$netconfDns]"  01-netcfg.yaml

netplan --debug generate
netplan --debug apply

apt-get -y -q install openssh-server

systemctl start sshd

ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow ssh
ufw allow 22
ufw enable

reboot
