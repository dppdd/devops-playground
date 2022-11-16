#!/bin/bash

echo "* Add hosts ..."
echo "192.168.99.101 docker1.home1.lab docker1" >> /etc/hosts
echo "192.168.99.102 docker2.home1.lab docker2" >> /etc/hosts
echo "192.168.99.103 docker3.home1.lab docker3" >> /etc/hosts

echo "* Install Additional Packages ..."
dnf install -y jq tree git nano

# We have two options:
# 1) Either disable the firewall
#    systemctl disable --now firewalld
# 2) Or open the ports required for Docker Swarm and any other requred by the applications
#    firewall-cmd --add-port=2377/tcp --permanent
#    firewall-cmd --add-port=4789/udp --permanent
#    firewall-cmd --add-port=7946/tcp --permanent
#    firewall-cmd --add-port=7946/udp --permanent
# Option 2 is implemented bellow

echo "* Firewall - swarm - open ports ..."
firewall-cmd --add-port=2377/tcp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent

echo "* Firewall - app - open port 8080 ..."
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
