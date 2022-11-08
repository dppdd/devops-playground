#!/bin/bash
# Init script for Ubuntu. The following is done here:
# Not here, but should be: Change SSH ports, generate SSH key for root, new port: 9292
# Install: Metricbeat


### Important ###
# Please hard code the IP of the master machine. 
# It could be added as param on later stage, no need for now.

master_ip=""


my_ip=$(hostname -I | cut -d ' ' -f 1)

echo_message() {
    terminalColorWarning='\033[1;34m'
    terminalColorClear='\033[0m'
    echo -e "${terminalColorWarning}$1${terminalColorClear}"
    echo
}

echo_message " Install Metricbeat"

wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.5.0-amd64.deb
sudo dpkg -i metricbeat-8.5.0-*
rm -f metricbeat-8.5.0-*

echo_message " Set up Metricbeat"

cp /etc/metricbeat/metricbeat.yml /etc/metricbeat/back.metricbeat.yml.backup
m_conf="/etc/metricbeat/metricbeat.yml"

# - Disable the Elasticsearch output (line #92) and enable the Logstash output (line #105) 
sed -i 's/output.elasticsearch:/#output.elasticsearch:/' $m_conf
sed -i 's/hosts: \["localhost:9200"\]/#hosts: \["localhost:9200"\]/'  $m_conf
sed -i 's/#output.logstash:/output.logstash:/' $m_conf
sed  -i 's/#hosts: \["localhost:5044"\]/hosts: \["localhost:5044"\]/' $m_conf

# - substitute localhost with Logstash server
sed -i "s/localhost:5044/${master_ip}:5044/" $m_conf 

# we can test the config, TODO: setup this as condition
metricbeat test config

# Start the service
systemctl daemon-reload
systemctl enable metricbeat
systemctl start metricbeat
