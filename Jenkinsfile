pipeline {
    agent { label 'agent2' } 

    stages {
        stage('Terraform vpcWest') {
            steps {
                withCredentials([
                    string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
                    string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')
                ]) {
                    dir('west') {
                        sh 'terraform init'
                        sh 'terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
                        sh 'terraform apply plan.tfplan'
                    }
                }
            }
        }
        stage('Deploy EKS') {
            steps {
                dir('west') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh 'chmod +x ./clusterw.sh'
                        sh './clusterw.sh'
                    }
                }
            }
        }
        stage('Peer Connect') {
            steps {
                dir('peering') {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY_ID'), 
                        string(credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh 'chmod +x ./vpc.sh'
                        sh './vpc.sh'
                    }
                }
            }
        }     
    }
}
