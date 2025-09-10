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
    stage('Publish Over SSH01') {
      steps {
        sshPublisher(publishers: [sshPublisherDesc(configName: 'web01', 
        transfers: [sshTransfer(cleanRemote: false, excludes: '', 
       execCommand: '''
        cd test
        echo 'hi 123' > hello.txt
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
        cd test
        echo 'hi 321' > hello.txt
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
