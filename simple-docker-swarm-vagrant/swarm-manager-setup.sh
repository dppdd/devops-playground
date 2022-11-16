#!/bin/bash
echo "-- Initiate Swarm"
docker swarm init --advertise-addr 192.168.99.101

echo "--  Output the token to file on vagrant host"
docker swarm join-token -q worker > /vagrant/worker-token.temp


