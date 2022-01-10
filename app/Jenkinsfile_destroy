pipeline {
    agent any
    stages {          
        stage('Run script') {
            steps {
                withAWS(credentials: 'baranikannan', region: 'ap-southeast-1') {
                    sh '''
                    aws s3 ls
                    cd app
                    sh ./destroy_env.sh ${app_version}
                    echo ${app_version}
                    '''
                }
            }
        }
    }
}