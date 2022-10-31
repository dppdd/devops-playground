#!/bin/bash
# This is a partial init script, made for CentOS 9 Stream. 
# By Partial, we mean instealling and configuring: SSH, Firewall, Docker...
# Then, manually running the required Docker containers - Prometheus, Grafana, Apps.

echoMsg() {
    terminalColorWarning='\033[1;34m'
    terminalColorClear='\033[0m'
    echo -e "${terminalColorWarning}$1${terminalColorClear}"
}


echoMsg " ----- SSH -----"

echoMsg " Configure Ports, generate keys, restart sshd"
# We change port as port 22 is often brute-forced by robots. 

echo "Port 9292" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

ssh-keygen -f ~/.ssh/ssh_key_cent_root -q -N ""
cat ~/.ssh/ssh_key_cent_root.pub >> ~/.ssh/authorized_keys

firewall-cmd --add-port=9292/tcp --permanent
firewall-cmd --reload

yum install -y policycoreutils-python-utils-3.3-5.el9
semanage port -a -t ssh_port_t -p tcp 9292
semanage port -m -t ssh_port_t -p tcp 9292

systemctl restart sshd


echoMsg " ----- Install Apps -----"

# Set PORTS here
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

# Install packages here
dnf install -y jq tree git nano wget

dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add user configuration in order to avoid using Root. Missing for now. TODO1


echoMsg "----- Completed. Read below! -----"

echo "Save the following private key to your local machine"
echo "Printing ~/.ssh/ssh_key_cent_root ..."
cat ~/.ssh/ssh_key_cent_root

my_ip=$(hostname -I | cut -d ' ' -f 1)
echo "ssh -i ssh_key_cent_root root@${my_ip} -p9292"
echo
