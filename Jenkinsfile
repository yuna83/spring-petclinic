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

    tools {
        maven "M3"
        jdk "JDK17"
    }

    environment {
        DOCKER_REPO = "yyn83/spring-petclinic"
    }

    stages {

        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
            }
        }

        stage('Maven Build') {
            steps {
                sh """
                mvn -Dmaven.test.failure.ignore=true clean package
                """
            }
        }

        stage('Kaniko Build & Push') {
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                      --context=${WORKSPACE} \
                      --dockerfile=${WORKSPACE}/Dockerfile \
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
            echo "🎉 유나! CI/CD 성공했어!"
        }
        failure {
            echo "⚠️ 유나.. 실패했는데 내가 도와줄게!"
        }
    }
}
