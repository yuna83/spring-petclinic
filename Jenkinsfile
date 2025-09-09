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
    stage('Publish Over SSH01') {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'web01', 
        transfers: [sshTransfer(cleanRemote: false, excludes: '', 
        execCommand: '''
        # 안전하게 정리
        docker rm -f $(docker ps -aq) 2>/dev/null || true
        docker images -q | xargs -r docker rmi -f || true
        
        # 백그라운드로 완전 분리하여 실행(스트림 끊기)
        nohup bash -lc "
          docker pull yyn83/spring-petclinic:latest || true
          docker run -d --restart=always -p 8080:8080 \
            --name=spring-petclinic yyn83/spring-petclinic:latest
        " </dev/null >/dev/null 2>&1 &
        
        # 즉시 성공 반환
        exit 0
        ''',
        execTimeout: 600000, 
        flatten: false, 
        makeEmptyDirs: false, 
        noDefaultExcludes: false, 
        patternSeparator: '[, ]+', 
        remoteDirectory: '', 
        remoteDirectorySDF: false, 
        removePrefix: 'web01', 
        sourceFiles: '')], 
        usePromotionTimestamp: false, 
        useWorkspaceInPromotion: false, 
        verbose: false)])
      }
    }

    stage('Publish Over SSH02') {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'web02', 
        transfers: [sshTransfer(cleanRemote: false, excludes: '', 
       execCommand: '''
        # 안전하게 정리
        docker rm -f $(docker ps -aq) 2>/dev/null || true
        docker images -q | xargs -r docker rmi -f || true
        
        # 백그라운드로 완전 분리하여 실행(스트림 끊기)
        nohup bash -lc "
          docker pull yyn83/spring-petclinic:latest || true
          docker run -d --restart=always -p 8080:8080 \
            --name=spring-petclinic yyn83/spring-petclinic:latest
        " </dev/null >/dev/null 2>&1 &
        
        # 즉시 성공 반환
        exit 0
        ''',
        execTimeout: 600000, 
        flatten: false, 
        makeEmptyDirs: false, 
        noDefaultExcludes: false, 
        patternSeparator: '[, ]+', 
        remoteDirectory: '', 
        remoteDirectorySDF: false, 
        removePrefix: 'web02', 
        sourceFiles: '')], 
        usePromotionTimestamp: false, 
        useWorkspaceInPromotion: false, 
        verbose: false)])
      }
    }
  }
}
