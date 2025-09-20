node {
    def mavenHome
    def mavenCMD
    def tagName = "3.0"
    
    stage('Prepare Environment') {
        echo 'Initializing all the variables'
        mavenHome = tool name: 'maven', type: 'maven'
        mavenCMD = "${mavenHome}/bin/mvn"
    }
    
    stage('Git Code Checkout') {
        try {
            echo 'Checkout the code from Git repository'
            git 'https://github.com/shubhamkushwah123/star-agile-insurance-project.git'
        } catch(Exception e) {
            echo 'Exception occurred in Git Code Checkout Stage'
            currentBuild.result = "FAILURE"
            emailext(
                body: """Dear All,
The Jenkins job ${JOB_NAME} has failed. Request you to please have a look immediately by clicking on the link below: 
${BUILD_URL}""",
                subject: "Job ${JOB_NAME} ${BUILD_NUMBER} FAILED",
                to: 'shubham@gmail.com'
            )
        }
    }
    
    stage('Build the Application') {
        echo "Cleaning, Compiling, Testing, Packaging..."
        sh "${mavenCMD} clean package"
    }
    
    stage('Publish Test Reports') {
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
    
    stage('Containerize the Application') {
        echo 'Creating Docker image'
        sh "docker build -t shubhamkushwah123/insure-me:${tagName} ."
    }
    
    stage('Push Docker Image to DockerHub') {
        echo 'Pushing Docker image to DockerHub'
        withCredentials([string(credentialsId: 'dock-password', variable: 'dockerHubPassword')]) {
            sh "docker login -u shubhamkushwah123 -p ${dockerHubPassword}"
            sh "docker push shubhamkushwah123/insure-me:${tagName}"
        }
    }
    
    stage('Configure and Deploy to Test Server') {
        ansiblePlaybook(
            become: true,
            credentialsId: 'ansible-key',
            disableHostKeyChecking: true,
            installation: 'ansible',
            inventory: '/etc/ansible/hosts',
            playbook: 'ansible-playbook.yml'
        )
    }
}
