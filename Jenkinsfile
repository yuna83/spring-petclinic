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

        // 📌 GitHub 소스코드 가져오기
        stage('Checkout') {
            steps {
                git branch: 'main', url: "https://github.com/yuna83/spring-petclinic.git"
            }
        }

        // 📌 Maven 빌드 → JAR 생성
        stage('Build JAR') {
            steps {
                sh "chmod +x mvnw"
                sh "./mvnw clean package -DskipTests"
            }
        }

        // 📌 Kaniko로 Docker Build & Push
        stage('Build & Push Docker (Kaniko)') {
            agent {
                kubernetes {
                    label 'kaniko-build'
                    defaultContainer 'kaniko'
                    yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: kaniko
spec:
  serviceAccountName: default
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker/
  restartPolicy: Never
  volumes:
  - name: docker-config
    projected:
      sources:
      - secret:
          name: dockerhub-secret
          items:
          - key: .dockerconfigjson
            path: config.json
"""
                }
            }
            steps {
                container('kaniko') {
                    sh """
/kaniko/executor \
  --context=$(pwd) \
  --dockerfile=Dockerfile \
  --destination=${DOCKER_REPO}:latest \
  --cache=true
"""
                }
            }
        }

        // 📌 Kubernetes에 새 이미지로 롤링 업데이트
        stage('Deploy to K8s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KCFG')]) {
                    sh """
                    export KUBECONFIG=$KCFG
                    kubectl set image deployment/petclinic petclinic=${DOCKER_REPO}:latest -n petclinic
                    kubectl rollout status deployment/petclinic -n petclinic
                    """
                }
            }
        }
    }
}
