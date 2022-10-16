pipeline
{
    agent any
    stages
    {
        stage('Setup Working Directory')
        {
            steps
            {
                sh '''
                    if [ ! -d /projects ]; then
                        sudo mkdir /projects
                        sudo chown jenkins: /projects
                    else
                        echo "The /projects directory already exists, skipping..."
                    fi
                '''
                script
                {
                    custom_variable = 'Demiro'
                }
            }
        }
        stage('Clone or Pull GIT Repository')
        {
            steps
            {
                sh '''
                    if [ -d $APP_ROOT ]; then
                        cd $APP_ROOT
                        git pull https://github.com/shekeriev/demobgapp
                    else
                        cd /projects
                        git clone https://github.com/shekeriev/demobgapp
                    fi
                '''
            }
        }
        stage('Apply corrections to ENV file and Docker Compose')
        {
            steps
            {
                sh '''
                    cd $APP_ROOT
                    rm -rf docker-compose-swarm.yaml .env
                    sed -i 's/8080/${LOCAL_ENV_PORT}/' docker-compose.yaml
                '''
            }
        }
        stage('Run the application')
        {
            steps
            {
                sh '''
                    cd $APP_ROOT
                    docker compose down || echo "Err on compose down"
                    docker compose up --detach || echo "Err on compose up"
                '''
            }
        }
    }
}