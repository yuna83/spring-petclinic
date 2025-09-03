pipeline {
  agent any 

  tools {
    maven "M3"
    jdk "JDK17"
  }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerCredentials')
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
    stage('Docker Hub Login') {
      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
      }
    }
    stage('Docker Image Push') {
      steps {
        sh 'docker push yyn83/spring-petclinic:latest'
      }
    }
    stage('Docker Image Remove') {
      steps {
        sh 'docker rmi yyn83/spring-petclinic:$BUILD_NUMBER yyn83/spring-petclinic:latest'
      }
    }
    stage('Publish Over SSH') {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'Target',
        transfers: [sshTransfer(cleanRemote: false, excludes: '', 
        execCommand: '''
        docker rm -f $(docker ps -aq)
        docker rmi $(docker images -q)
        docker run -itd -p 8080:8080 --name=spring-petclinic yyn83/spring-petclinic:latest
        ''', 
        execTimeout: 120000, 
        flatten: false, 
        makeEmptyDirs: false, 
        noDefaultExcludes: false, 
        patternSeparator: '[, ]+', 
        remoteDirectory: '', 
        remoteDirectorySDF: false, 
        removePrefix: 'target', 
        sourceFiles: '')], 
        usePromotionTimestamp: false, 
        useWorkspaceInPromotion: false, 
        verbose: false)])
      }
    }
  }
}
