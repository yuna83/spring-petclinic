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

        // 📌 1. GitHub에서 최신 소스코드 가져오기
        stage('Checkout') {
            steps {
                git branch: 'main', url: "https://github.com/yuna83/spring-petclinic.git"
            }
        }

        // 📌 2. Maven으로 Spring Boot JAR 빌드
        stage('Build JAR') {
            steps {
                sh "chmod +x mvnw"
                sh "./mvnw clean package -DskipTests"
            }
        }

        // 📌 3. Kaniko로 Docker 이미지 빌드 + DockerHub 자동 Push
        stage('Build & Push Docker (Kaniko)') {
            agent {
                kubernetes {
                    label 'kaniko-build'            // 빌드 실행할 Pod의 라벨
                    defaultContainer 'kaniko'       // 기본 실행 컨테이너
                    yamlFile null                   // 외부 yaml 파일 사용 안함
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

                    // Kaniko Executor 로 이미지 빌드 & 업로드
                    sh """
                    /kaniko/executor \
                      --context `pwd` \              // 현재 workspace → Docker build context
                      --dockerfile Dockerfile \      // 사용할 Dockerfile
                      --destination ${DOCKER_REPO}:latest \    // DockerHub Push
                      --cache=true                   // Kaniko 캐시 (빌드 속도 향상)
                    """
                }
            }
        }

        // 📌 4. Kubernetes Deployment 업데이트
        stage('Deploy to K8s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KCFG')]) {

                    sh """
                    export KUBECONFIG=$KCFG

                    # Deployment의 컨테이너 이미지를 최신 버전으로 교체
                    kubectl set image deployment/petclinic \
                        petclinic=${DOCKER_REPO}:latest \
                        -n petclinic

                    # 롤링 업데이트 완료될 때까지 대기
                    kubectl rollout status deployment/petclinic -n petclinic
                    """
                }
            }
        }
    }
}
