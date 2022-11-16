pipeline
{
    agent any
    environment
    {
        LOCAL_ENV_PORT = '9090'
        APP_ROOT = '/projects/demobgapp'
        PROJECT_ROOT = '/projects/demobgapp/web'
        DB_ROOT_PASSWORD = '12345'
    }
    stages
    {
        stage('Init')
        {
            steps
            {
                echo 'Master: Initialization Stage'
            }
        }
        stage('Do')
        {
            steps
            {
                echo 'Master: Build Slave'
                build job: 'PL-Slave',
                parameters:
                [
                    string(name:'LOCAL_ENV_PORT', value: "${LOCAL_ENV_PORT}"),
                    string(name:'APP_ROOT', value: "${APP_ROOT}"),
                    string(name:'PROJECT_ROOT', value: "${PROJECT_ROOT}"),
                    string(name:'DB_ROOT_PASSWORD', value: "${DB_ROOT_PASSWORD}")
                ]
            }
        }
        stage('Done')
        {
            steps
            {
                echo 'Master: Execution Complete'
            }
        }
    }
}