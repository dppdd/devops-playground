This is a simple test creating Elastic Search stack on three nodes, without docker. 
Check the init scripts for more info.

Infrastructure:

hostname: master
os: centos
IP: $
Init_script: ./master-centos-init.sh

hostname: client1:
os: centos
IP: $
Init_script: ./client-centos-init.sh

client2:
os: ubuntu
IP: $
Init_script: ./client-debian-init.sh

