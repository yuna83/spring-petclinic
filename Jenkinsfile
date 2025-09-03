pipeline {
  agent any 

  tools {
    maven "M3"
    jdk "JDK17"
  }
  
  stages{
    stage('Git Clone'){
      steps {
        git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
      }
    }
    stage('Maven Build'){
      steps {
        sh 'mvn -Dmaven.test.failure.ignore=true clean package'
      }    
    }
    stage('Docker Image Create'){
      steps {
        sh """
        docker build -t yyn83/spring-petclinic:$BUILD_NUMBER .
        docker tag yyn83/spring-petclinic:$BUILD_NUMBER yyn83/spring-petclinic:latest
        """
      }
    }
  }
}
