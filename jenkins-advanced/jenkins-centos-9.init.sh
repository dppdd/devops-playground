#!/bin/bash
### Initial script for configuring:
#   CentOS 9 Stream instance
#   Jenkins
# author: demiro
# SSH the instance and execute this script. No params expected.

echo "#### Part I: SSH Configuration ####"

# Replace port 22 with 9292
echo "Port 9292" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Generate and authorize SSH key
ssh-keygen -f ~/.ssh/ssh_key_jenkins_root -q -N ""
cat ~/.ssh/ssh_key_jenkins_root.pub >> ~/.ssh/authorized_keys

# Allow port
firewall-cmd --add-port=9292/tcp --permanent
firewall-cmd --reload

yum install -y policycoreutils-python-utils-3.3-5.el9
semanage port -a -t ssh_port_t -p tcp 9292
semanage port -m -t ssh_port_t -p tcp 9292

# Restart SSHD
systemctl restart sshd

echo "#### Part I: SSH Configuration Completed ####"

echo "Part II: Install Java and Jenkins"

sudo yum install wget -y
# Jenkins
sudo wget https://pkg.jenkins.io/redhat/jenkins.repo -O /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo dnf makecache
sudo dnf install jenkins -y
# Java
sudo dnf install java-17-openjdk -y
# Firewall
echo "* Firewall - open port 8080 ..."
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload
echo "* Start Jenkins ..."
sudo systemctl start jenkins
sudo systemctl enable jenkins
# Setup jenkins user
sudo usermod -s /bin/bash jenkins
echo 'Password1' | passwd --stdin jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Restart jenkins
sudo systemctl restart jenkins

echo "* Install Additional packages"
dnf install -y jq tree git nano

echo "* Part II Completed"


echo "***** Further Instructions *****"

echo "Save the following private key to your local machine"
echo "Printing ~/.ssh/ssh_key_master ..."
cat ~/.ssh/ssh_key_jenkins_root

echo
echo "Then test the connection with:"
my_ip=$(hostname -I | cut -d ' ' -f 1)
echo "ssh -i ssh_key_jenkins_root root@${my_ip} -p9292"
echo
echo "Complete the Jenkins installation at ${my_ip}:8080"
echo "copy the key in /var/lib/jenkins/secrets/initialAdminPassword"