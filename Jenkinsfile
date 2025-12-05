pipeline {
  agent any
  stages {
    stage('SSH Test') {
      steps {
        sshagent(credentials: ['k8s-master-ssh']) {
          sh 'ssh -o StrictHostKeyChecking=no ubuntu@192.168.20.101 "echo SSH OK"'
        }
      }
    }
  }
}
