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
      stage('scp jar') {
          steps {
              sh '''
                  scp /home/ubuntu/jenkins/jenkins_home/workspace/Pilpeline-web/target/spring-petclinic-3.5.0-SNAPSHOT.jar \
                  rocky@172.16.32.11:/home/rocky/deploy/
              '''
          }
      }

      stage('SSH Publish') {
            steps {
                echo 'SSH Publish'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'web01', 
                transfers: [sshTransfer(cleanRemote: false, 
                excludes: '', 
                execCommand: '''
                fuser -k 8080/tcp
                export BUILD_ID=Petclinic-Pipeline
                nohup java -jar /home/rocky/deploy/spring-petclinic-3.5.0-SNAPSHOT.jar >> nohup.out 2>&1 &''', 
                execTimeout: 120000, 
                flatten: false, 
                makeEmptyDirs: false, 
                noDefaultExcludes: false, 
                patternSeparator: '[, ]+', 
                remoteDirectory: '', 
                remoteDirectorySDF: false, 
                removePrefix: 'target', 
                sourceFiles: 'target/*.jar')], 
                usePromotionTimestamp: false, 
                useWorkspaceInPromotion: false, verbose: false)])
            }
        }
  }
}
