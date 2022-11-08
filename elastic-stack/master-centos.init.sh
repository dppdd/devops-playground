#!/bin/bash
# Init script for CentOS 9 Stream. The following is done here:
# Change SSH ports, generate SSH key for root, new port: 9292
# Allow all required ports for the apps below.
# Install: Elastic Search, Logstash, Kibana : 8.5.0
# Print out the Private key and SSH string.

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

firewall-cmd --add-port 9200/tcp --permanent
firewall-cmd --add-port 5601/tcp --permanent
firewall-cmd --add-port 5044/tcp --permanent
sudo firewall-cmd --reload

echo_message " ----- Firewall Done ----- "


echo_message " ----- Applications ----- "
# Install: Elastic Search, Logstash, Kibana
dnf install -y jq tree git wget

echo_message " Install Elastic Search"

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.5.0-x86_64.rpm
sudo rpm -Uvh elasticsearch-*.rpm
rm -f elasticsearch-*.rpm

# Set up Elastic Search

# Set Java heap size:
echo '-Xms2g' > /etc/elasticsearch/jvm.options.d/jvm.options
echo '-Xmx2g' >> /etc/elasticsearch/jvm.options.d/jvm.options
chown root:elasticsearch /etc/elasticsearch/jvm.options.d/jvm.option

# edit /etc/elasticsearch/elasticsearch.yml
my_ip=$(hostname -I | cut -d ' ' -f 1)
es_main_config='/etc/elasticsearch/elasticsearch.yml'
sed -i 's/#network.host: 192.168.0.1/network.host: ["localhost", "${my_ip}"]/' $es_main_config
sed -i 's/#http.port: 9200/http.port: 9200/' $es_main_config
sed -i 's/#cluster.name: my-application/cluster.name: mycluster/' $es_main_config
sed -i 's/#node.name: node-1/node.name: master/' $es_main_config
sed  -i 's/cluster.initial_master_nodes/#cluster.initial_master_nodes/' $es_main_config
echo 'cluster.initial_master_nodes: ["master"]' >> $es_main_config

# Turn Off the Security Mode of Elasticsearch: (Not recommended, just for these tests)


# Start the service:
systemctl daemon-reload
systemctl enable elasticsearch
systemctl start elasticsearch
systemctl restart elasticsearch

# Generate new password and save it to /es_pass_izx526487
yes | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic --force --auto -s > /root/es_pass_izx526487


echo_message " Install Logstash"

wget https://artifacts.elastic.co/downloads/logstash/logstash-8.5.0-x86_64.rpm
sudo rpm -Uvh logstash-*.rpm
rm -f logstash-*.rpm

# Test with
#  /usr/share/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'
# You can change java heap size in /etc/logstash/jvm.options

# Configure beats pipeline
cat << EOF > /etc/logstash/conf.d/beats.conf
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOF

systemctl start logstash
systemctl status logstash


echo_message " Install Kibana"
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.5.0-x86_64.rpm
rpm -Uvh kibana-*.rpm
rm -f kibana-*.rpm

# Post config Kibana
ki_conf="/etc/kibana/kibana.yml"
cp /etc/kibana/kibana.yml /etc/kibana/backup.kibana.yml.backup

sed -i 's/#server.port/server.port/' $ki_conf
sed -i "s/#server.host: \"localhost\"/server.host: \"${my_ip}\"/" $ki_conf
sed -i 's/#server.name: "your-hostname"/server.name: "master"/' $ki_conf
sed -i 's/#elasticsearch.hosts/elasticsearch.hosts/' $ki_conf

systemctl daemon-reload
systemctl enable kibana
systemctl start kibana