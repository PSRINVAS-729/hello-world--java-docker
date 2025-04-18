pipeline {
    agent any

    environment {
        s3Bucket = "tests3k8sdemo"
        scannerHome = tool name: 'sonar-scanner'
        ecrrepo = "619071336245.dkr.ecr.ap-south-1.amazonaws.com/demo"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                checkout scm
            }
        }

        stage('Build with Maven') {
            steps {
                script {
                    try {
                        sh "mvn clean install"
                    } catch (err) {
                        currentBuild.result = 'FAILURE'
                        error "Maven build failed!"
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-scanner') {
                    sh """
                        ${scannerHome}/bin/sonar-server \
                        -Dsonar.projectName=jenkins \
                        -Dsonar.projectKey=jenkins \
                        -Dsonar.java.binaries=target/classes \
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token'
                }
            }
        }
    }
}
	

