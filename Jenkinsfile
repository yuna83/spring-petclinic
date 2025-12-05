pipeline {
    agent any

    tools {
        maven "M3"
        jdk "JDK17"
    }

    environment {
        DOCKER_REPO = "yyn83/petclinic"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: "https://github.com/yuna83/spring-petclinic.git"
            }
        }

        stage('Build JAR') {
            steps {
                sh "chmod +x mvnw"
                sh "./mvnw clean package -DskipTests"
            }
        }

        stage('Build & Push Docker (Kaniko)') {
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/kaniko/executor"]
    args:
      - "--dockerfile=Dockerfile"
      - "--context=dir:///workspace"
      - "--destination=${DOCKER_REPO}:latest"
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker/
  restartPolicy: Never
  volumes:
  - name: docker-config
    secret:
      secretName: regcred
      items:
      - key: .dockerconfigjson
        path: config.json
"""
                }
            }
            steps {
                sh "echo 'Kaniko Build Starting'"
            }
        }

        stage('Deploy to K8s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
export KUBECONFIG=$KUBECONFIG_FILE
kubectl set image deployment/petclinic petclinic=${DOCKER_REPO}:latest -n petclinic
kubectl rollout status deployment/petclinic -n petclinic
                    '''
                }
            }
        }
    }
}
