pipeline {
    agent any

    environment {
        MAVEN_HOME = tool name: 'maven', type: 'maven'
        MAVEN_CMD = "${MAVEN_HOME}/bin/mvn"
        TAG_NAME = "3.0"
        DOCKER_IMAGE = "nitin0091/insure-me:${TAG_NAME}"
    }

    stages {
        stage('Prepare Environment') {
            steps {
                echo "Environment initialized"
            }
        }

        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Nitin201/Insure-Me-Insurance.git'
            }
        }

        stage('Build Application') {
            steps {
                echo "Cleaning, compiling, testing, packaging..."
                sh "${MAVEN_CMD} clean package"
            }
        }

        stage('Publish Test Reports') {
            steps {
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: false,
                    reportDir: 'target/surefire-reports',
                    reportFiles: 'index.html',
                    reportName: 'HTML Report',
                    useWrapperFileDirectly: true
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${DOCKER_IMAGE}"
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo "Pushing Docker image to DockerHub"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy to Test Server') {
            steps {
                echo "Deploying via Ansible using workspace inventory file"
                ansiblePlaybook(
                    become: true,
                    credentialsId: 'ansible-key',
                    disableHostKeyChecking: true,
                    installation: 'ansible',  
                    inventory: "${pwd()}/ansible/inventory.ini", // Use workspace path
                    playbook: "${pwd()}/ansible-playbook.yml"
                )
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
            emailext(
                body: """Dear All,
The Jenkins job ${JOB_NAME} has failed. Please check the details at ${BUILD_URL}""",
                subject: "Job ${JOB_NAME} ${BUILD_NUMBER} FAILED",
                to: 'shubham@gmail.com'
            )
        }
    }
}
