pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-ci
spec:
  serviceAccountName: jenkins
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command:
    - cat
    tty: true
    volumeMounts:
    - name: maven-cache
      mountPath: /root/.m2

  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: kaniko-cache
      mountPath: /kaniko/.cache
    - name: docker-config
      mountPath: /kaniko/.docker/

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: kubeconfig
      mountPath: /root/.kube
      readOnly: true

  volumes:
  - name: maven-cache
    hostPath:
      path: /data/maven-cache
  - name: kaniko-cache
    hostPath:
      path: /data/kaniko-cache
  - name: docker-config
    secret:
      secretName: dockertoken
      items:
      - key: .dockerconfigjson
        path: config.json
  - name: kubeconfig
    secret:
      secretName: jenkins-kubeconfig
            """
        }
    }

    environment {
        DOCKER_REPO = "yyn83/spring-petclinic"
    }

    stages {

        stage('Git Clone') {
            steps {
                container('maven') {
                    git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
                }
            }
        }

        stage('Maven Build') {
            steps {
                container('maven') {
                    sh """
                    mvn -Dmaven.test.failure.ignore=true clean package
                    """
                }
            }
        }

        stage('Kaniko Build & Push') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                      --context=`pwd` \
                      --dockerfile=`pwd`/Dockerfile \
                      --destination=${DOCKER_REPO}:${BUILD_NUMBER} \
                      --destination=${DOCKER_REPO}:latest \
                      --cache=true
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh """
                    kubectl set image deployment/petclinic \
                        petclinic=${DOCKER_REPO}:${BUILD_NUMBER} \
                        -n app

                    kubectl rollout status deployment/petclinic -n app
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 CI/CD 성공! 유나 잘했어!"
        }
        failure {
            echo "⚠️ CI/CD 실패.. 유나 내가 같이 도와줄게!"
        }
    }
}
