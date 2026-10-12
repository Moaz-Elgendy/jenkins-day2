
pipeline {
    agent any

    stages {
        stage('Hello World') {
            steps {
                echo 'Hello World'
            }
        }

        stage('Run Script') {
            steps {
                sh '''
                    chmod +x hello.sh
                    ./hello.sh
                '''
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed!'
        }

        aborted {
            echo 'Pipeline was aborted!'
        }
    }
}
