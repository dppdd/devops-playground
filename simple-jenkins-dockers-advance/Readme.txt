--- Cloud setup, e.g. Linode ---

*** Create two instances. Name them jenkins-host and docker-host
*** Run the following 

- jenkins-host
./jenkins-centos-9.init.sh

- docker-host
./docker-centos-9.init.sh # requires docker-compose.yml for Gitea

*** Manual steps on jenkins-host, not required, could be included in the init scripts:
ssh-keygen -t ecdsa -b 521 -m PEM
ssh-copy-id -p 9292 jenkins@$IP_JENKINS # copy to jenkins machine
ssh-copy-id -p 9292 jenkins@$IP_DOCKER # copy to docker machine


*** Jenkins UI post-configuration:

1. Manage Jenkins > Manage Credentials > System > Global > Add Credentials
- Username with password - "Local user with password"
- SSH Username with private key: jenkins & /var/lib/jenkins/.ssh/id_ecdsa - "Credentials from file"
2. Manage Jenkins > Manage Plugins > Available
- SSH install and restart
3. Manage Jenkins > Configure System > SSH remote hosts / SSH sites > Add
- hostname: $IP_JENKINS, Port: 9292, Credentials: "Credentials from file" (jenkins machine)
- hostname: $$IP_DOCKER, Port: 9292, Credentials: "Credentials from file"  (docker machine)
4. Manage Jenkins > Manage Nodes and Clouds > New Node
- Node name: docker-node, Permanent Agent, save:
- Number of executors: 4, Remote root: /home/jenkins, Labels: docker-node
- Usage: Only build jobs with label expression matching this node
- Launch method: Launch agents via SSH
- Credentials: "Credentials from file", Advanced: Port: 9292

Part I: Set up Gitea repo and make Jenkins pipeline

Gitea steps:
+ > New Repository > Migrate repository > GIT 
Clone from: https://github.com/shekeriev/bgapp # we use this nice sample php app
Repo name: bgapp
- on my local machine:
git clone http://170.187.185.37:3000/demiro/bgapp
Changes to the original repo:
- change Document root in docker-compose yaml
- clean some unuseful files
- Create Jenkinsfile, content in:
./Jenkinsfile
- create docker-compose.yml, content in: 
./docker-files/staging-env/
- create production-containers/docker-compose.yml, content in: 
./docker-files/prod-env/

commit and push


Jenkins: Build pipeline
- GitHub project: http://$IP_DOCKER:3000/demiro/bgapp/
- Pipeline script from SCM : GIT : Jenkinsfile

Part II: Set up Gitea Webhook

Jenkins:
1. Manage Jenkins > Manage Plugins > Available > install Gitea
2. Select Pipeline > Configure > Build Triggers
- GitHub hook trigger for GITScm polling
- Poll SCM

Gitea:
1. Select Repo > Settings > webhooks > add > 
http://$IP_JENKINS:8080/gitea-webhook/post
> Test Delivery
> Test II: Change in git, commit and push


Complete the Jenkins pipeline steps with:
(content in Jenkinsfile)
- Testing the application for reachability.
- Publishing the images to Docker Hub
- Stopping the application and removing the containers
- Using another Docker Compose file to
 - Create a common network
 - Run the containers (the web container to publish port on 80)