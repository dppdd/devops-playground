#!/bin/bash

echo "* Add Docker repository ..."
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "* Install Docker ..."
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "* Enable and start Docker ..."
systemctl enable docker
systemctl start docker