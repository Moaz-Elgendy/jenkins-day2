pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stg', 'prod'],
            description: 'Choose an Environment to terraform'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh '''
                    sudo apt-get update
                '''

                sh '''
                    if ! command -v terraform >/dev/null 2>&1; then
                        echo "Terraform not found -> installing..."
                        sudo apt-get install -y gnupg software-properties-common curl unzip
                        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
                        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
                        sudo apt-get update
                        sudo apt-get install -y terraform
                    else
                        echo "Terraform already installed: $(terraform version | head -n 1)"
                    fi
                '''

                sh '''
                    if ! command -v aws >/dev/null 2>&1; then
                        echo "AWS CLI not found -> installing..."
                        curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                        unzip -q awscliv2.zip
                        sudo ./aws/install
                        rm -rf awscliv2.zip aws
                    else
                        echo "AWS CLI already installed: $(aws --version)"
                    fi
                '''
            }
        }

        stage('Configure AWS CLI') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        aws configure set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
                        aws configure set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
                        aws configure set region "${AWS_DEFAULT_REGION}"
                        echo "AWS CLI configured for user $(whoami)"
                    '''
                }
            }
        }

        stage('Prepare Workspace Directory') {
            steps {
                sh '''
                    mkdir -p terraform-${ENVIRONMENT}
                    cd terraform-${ENVIRONMENT}
                    mv ../*.tf ../*.tfvars ./ 2>/dev/null || true
                    echo "Files moved into terraform-${ENVIRONMENT}:"
                    ls -la
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    cd terraform-${ENVIRONMENT}
                    terraform init
                '''
            }
        }

        stage('Select or Create Workspace') {
            steps {
                sh '''
                    cd terraform-${ENVIRONMENT}
                    if terraform workspace list | awk '{print $NF}' | grep -qx "${ENVIRONMENT}"; then
                        echo "Workspace '${ENVIRONMENT}' already exists -> selecting it"
                        terraform workspace select ${ENVIRONMENT}
                    else
                        echo "Workspace '${ENVIRONMENT}' does not exist -> creating it"
                        terraform workspace new ${ENVIRONMENT}
                    fi
                    terraform workspace show
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    cd terraform-${ENVIRONMENT}
                    terraform plan --var-file=${ENVIRONMENT}.tfvars -out=${ENVIRONMENT}-v1
                '''
            }
        }

        stage('Terraform Apply') {
            options {
                timeout(time: 30, unit: 'MINUTES')
            }
            steps {
                input message: "Please review the Terraform plan for '${params.ENVIRONMENT}' above. Apply this plan?", ok: 'Apply'
                sh '''
                    cd terraform-${ENVIRONMENT}
                    terraform apply -auto-approve ${ENVIRONMENT}-v1
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded! Environment ${params.ENVIRONMENT} — Terraform applied the VPC successfully."
        }

        failure {
            echo 'Pipeline failed! Sending email ...'
            emailext(
                subject: "Jenkins pipeline failed!",
                body: """
                Job: ${env.JOB_NAME}
                Build: ${env.BUILD_NUMBER}
                Status: ${currentBuild.currentResult}
                Environment: ${params.ENVIRONMENT}

                Check the logs:
                ${env.BUILD_URL}
                """,
                to: 'moazanas2000@gmail.com'
            )
        }

        aborted {
            echo 'Pipeline was aborted!'
        }
    }
}
