#!/bin/bash
### Initial script for configuring 
#   CentOS 9 Stream instance
#   Docker & Docker compose
#   Gitea
# author: demiro

echo "#### Part I: SSH Configuration ####"

echo "Port 9292" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Generate and authorize SSH key
ssh-keygen -f ~/.ssh/ssh_key_docker_root -q -N ""
cat ~/.ssh/ssh_key_docker_root.pub >> ~/.ssh/authorized_keys

# Allow ports
firewall-cmd --add-port=9292/tcp --permanent
firewall-cmd --reload

yum install -y policycoreutils-python-utils-3.3-5.el9
semanage port -a -t ssh_port_t -p tcp 9292
semanage port -m -t ssh_port_t -p tcp 9292

# Restart SSHD
systemctl restart sshd

echo "#### Part I: SSH Configuration Completed ####"

echo "Part II: Install Docker"

echo "* Add Docker repository ..."
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "* Install Docker along with Docker Compose as plugin..."
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "* Enable and start Docker ..."
systemctl enable docker
systemctl start docker

echo "* Firewall - open port 8080 ..."
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

echo "* Add jenkins user to docker group ..."
useradd jenkins
echo 'Password1' | passwd --stdin jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
usermod -s /bin/bash jenkins
usermod -aG docker jenkins

echo "* Install Additional packages"
dnf install -y jq tree git nano
# Java
sudo dnf install java-17-openjdk -y

echo "* Part II Completed"

echo "* Part III Install Idea"
# Port 3000
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

docker compose up -d

echo "***** Further Instructions *****"

echo "Save the following private key to your local machine"
echo "Printing ~/.ssh/ssh_key_docker_root ..."
cat ~/.ssh/ssh_key_docker_root

echo
echo "Then test the connection with:"
my_ip=$(hostname -I | cut -d ' ' -f 1)
echo "ssh -i ssh_key_docker_root root@${my_ip} -p9292"
echo
echo "Complete the Idea installation at ${my_ip}:3000"