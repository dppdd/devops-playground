This is a simple test creating Elasticsearch stack on three nodes, without docker.
No vagrant boxes, so you can use the following template for more info on the init
scripts and envs.

- Node 1 -
hostname: master
os: CentOS 9 Stream
IP: $
Init_script: ./master-centos-init.sh

- Node 1 -
hostname: client1
os: CentOS
IP: $
Init_script: ./client-centos-init.sh

- Node 2 -
hostname: client2
os: Ubuntu
IP: $
Init_script: ./client-debian-init.sh


Helper scripts:
create-data-view-api.sh - New data view, sample data view for metricbeat.

