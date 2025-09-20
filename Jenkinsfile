pipeline {
    agent any

    environment {
        TAG_NAME = "3.0"
    }

    stages {

        stage('Prepare Environment') {
            steps {
                echo "Initializing environment..."
                script {
                    MAVEN_HOME = tool name: 'maven', type: 'maven'
                    MAVEN_CMD = "${MAVEN_HOME}/bin/mvn"
                }
            }
        }

        stage('Git Checkout') {
            steps {
                echo "Checking out code from Git repository"
                git branch: 'master', url: 'https://github.com/Nitin201/Insure-Me-Insurance.git'
            }
        }

        stage('Build Application') {
            steps {
                echo "Cleaning, Compiling, Testing, Packaging..."
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
                echo "Creating Docker image"
                sh "docker build -t nitin0091/insure-me:${TAG_NAME} ."
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo "Pushing Docker image to DockerHub"
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push nitin0091/insure-me:${TAG_NAME}"
                }
            }
        }

        stage('Deploy to Test Server') {
            steps {
                echo "Deploying via Ansible using workspace-relative inventory"
                ansiblePlaybook(
                    installation: 'ansible',                  // Must match Jenkins global tool name
                    inventory: 'ansible/inventory.ini',       // Relative to workspace
                    playbook: 'ansible-playbook.yml',         // Relative to workspace
                    become: true,
                    credentialsId: 'ansible-key',             // SSH key stored in Jenkins
                    disableHostKeyChecking: true
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
                to: 'nitindodamani101@gmail.com',
                subject: "Jenkins Job ${JOB_NAME} #${BUILD_NUMBER} FAILED",
                body: """Dear All,

The Jenkins job ${JOB_NAME} has failed. Please check the details at ${BUILD_URL}"""
            )
        }
    }
}
