echo "-- Install Jenkins"
sudo wget https://pkg.jenkins.io/redhat/jenkins.repo -O /etc/yum.repos.d/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
sudo dnf install jenkins -y
# sudo dnf config-manager --disablerepo jenkins # disable repo to avoid accidental update

echo "-- Install Java 17"
sudo dnf install java-17-openjdk -y

echo "-- Mod jenkins linux user"
sudo usermod -s /bin/bash jenkins
echo 'Password1' | sudo passwd --stdin jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

echo "-- Firewall"
sudo firewall-cmd --permanent --add-port=9090/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --reload

echo "-- Start and enable jenkins"
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "-- Add jenkins and vagrant to docker group"
sudo usermod -aG docker vagrant
sudo usermod -aG docker jenkins

echo "-- Restart jenkins & docker services"
sudo systemctl restart jenkins
sudo systemctl restart docker

echo ""
echo " Navigate to http://192.168.99.101:8080/"
echo " Jenkins key:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword