#!/bin/bash
# Init script for CentOS 9 Stream. The following is done here:
# Change SSH ports, generate SSH key for root, new port: 9292
# Allow all required ports for the apps below.
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

echo_message " ----- SSH ----- "

echo_message " Configure Ports, generate keys, restart sshd"

yum install -y policycoreutils-python-utils-3.3-5.el9
firewall-cmd --add-port=9292/tcp --permanent
firewall-cmd --reload
semanage port -a -t ssh_port_t -p tcp 9292
semanage port -m -t ssh_port_t -p tcp 9292

echo "Port 9292" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

ssh-keygen -f ~/.ssh/ssh_key_cent_root -q -N ""
cat ~/.ssh/ssh_key_cent_root.pub >> ~/.ssh/authorized_keys

systemctl restart sshd

echo_message " ----- SSH Done ----- "

echo_message " ----- Firewall ----- "
echo_message " ----- Firewall Done ----- "


echo_message " ----- Applications ----- "
dnf install -y jq tree git wget

echo_message " Install Metricbeat"

wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-8.5.0-x86_64.rpm
rpm -Uvh metricbeat-8.*
rm -f metricbeat-8.*

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

# Install the beat’s template in Elasticsearch (once, no need on the next nodes):
metricbeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["'${master_ip}':9200"]'

# Start the service
systemctl daemon-reload
systemctl enable metricbeat
systemctl start metricbeat