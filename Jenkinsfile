pipeline {
  agent any

  tools {
    maven "M3"
    jdk "JDK17"
  }

  environment {
    DOCKERHUB = credentials('dockerCredentials')
  }

  stages {

    stage('Git Clone') {
      steps {
        git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
      }
    }

    stage('Maven Build') {
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true clean package'
      }
    }

    stage('Build & Push Image on Master Node') {
      steps {
        sshagent(credentials: ['k8s-master-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ubuntu@192.168.20.101 '
              cd /home/ubuntu/petclinic &&
              cp ${WORKSPACE}/target/*.jar ./app.jar &&
              echo "$DOCKERHUB_PSW" | docker login -u "$DOCKERHUB_USR" --password-stdin &&
              docker build -t yyn83/spring-petclinic:${BUILD_NUMBER} . &&
              docker push yyn83/spring-petclinic:${BUILD_NUMBER} &&
              docker tag yyn83/spring-petclinic:${BUILD_NUMBER} yyn83/spring-petclinic:latest &&
              docker push yyn83/spring-petclinic:latest
            '
          """
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sshagent(credentials: ['k8s-master-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no ubuntu@192.168.20.101 '
              kubectl set image deployment/petclinic petclinic=yyn83/spring-petclinic:${BUILD_NUMBER} -n default
            '
          """
        }
      }
    }

  }
}
