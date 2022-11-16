#!/bin/bash
### Initial script for configuring 
#   CentOS 9 Stream instance
#   Docker & Docker compose
#   Gitea

echo_() {
    terminalColorWarning='\033[1;34m'
    terminalColorClear='\033[0m'
    echo -e "${terminalColorWarning}$1${terminalColorClear}"
    echo
}


echo_ " ----- SSH ----- "

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

echo_ " ----- Install Docker ----- "
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

useradd jenkins
echo 'Password1' | passwd --stdin jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
usermod -s /bin/bash jenkins
usermod -aG docker jenkins

dnf install -y jq tree git nano

echo_ " ----- Install Java 17 ----- "
sudo dnf install java-17-openjdk -y


echo_ " ----- Install Gitea ----- "
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

docker compose up -d

echo_ " ----- Instructions Read Here ----- "

echo_ "Printing ~/.ssh/ssh_key_docker_root ..."
cat ~/.ssh/ssh_key_docker_root
echo

echo_ "Then test the connection with:"
my_ip=$(hostname -I | cut -d ' ' -f 1)

echo_ "ssh -i ssh_key_docker_root root@${my_ip} -p9292"
echo_ "Complete the Idea installation at ${my_ip}:3000"