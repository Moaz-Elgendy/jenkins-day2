
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
            echo 'Pipeline failed! Sending email ...'
	    emailext(
		  subject: "Jenkins pipeline failed!",
		  body: """
                    Job: ${env.JOB_NAME}
                    Build: ${env.BUILD_NUMBER}
                    Status: ${currentBuild.currentResult}

                    Check the logs:
                    ${env.BUILD_URL}
		    """,
		   to: ' moazanas2000@gmail.com'
		)
        }

        aborted {
            echo 'Pipeline was aborted!'
        }
    }
}
