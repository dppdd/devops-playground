#!/bin/bash

echo "* Join cluster as a worker"
docker swarm join --token $(cat /vagrant/worker-token.temp) 192.168.99.101:2377 &>> /vagrant/init.log