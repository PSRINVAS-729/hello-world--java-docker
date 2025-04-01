pipeline {
    agent any

    environment {
        s3Bucket = "myartifactor"
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
                git branch: 'main', credentialsId: 'Github', url: 'https://github.com/PSRINVAS-729/hello-world--java-docker.git'
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
                withSonarQubeEnv('sonar-server') {
                    sh """
                        ${scannerHome}/bin/sonar-scanner \
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

        stage('Trivy File Scan') {
            steps {
                sh "trivy fs . > trivy-fs_report.txt"
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Upload to S3') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                    sh "aws s3 cp target/*.jar s3://${s3Bucket}/${JOB_NAME}-${BUILD_NUMBER}/"
                }
            }
        }

        stage('Docker Build & Push to AWS ECR') {
            steps {
                script {
                    try {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                            sh """
                                aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${ecrrepo}
                                docker build -t demo .
                                docker tag demo ${ecrrepo}:latest
                                docker push ${ecrrepo}:latest
                            """
                        }
                    } catch (err) {
                        currentBuild.result = 'FAILURE'
                        error "Docker Build & Push to AWS ECR failed!"
                    }
                }
            }
        }

        stage('TRIVY Image Scan') {
            steps {
                script {
                    try {
                        sh "trivy image ${ecrrepo}:latest > trivy.json"
                    } catch (err) {
                        currentBuild.result = 'FAILURE'
                        error "Trivy Image Scan failed!"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully."
            // You can send success notifications here, if needed
        }
        failure {
            echo "Pipeline failed"
            // Send notification on failure (example with email)
            mail to: 'srinivasdevops381@gmail.com',
                 subject: "Jenkins Pipeline Failed: ${JOB_NAME}",
                 body: "Pipeline failed at stage: ${env.STAGE_NAME}\nError: ${currentBuild.result}"
        }
    }
}
