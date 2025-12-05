pipeline {
    agent any

    tools {
        maven "M3"
        jdk "JDK17"
    }

    environment {
        DOCKER_REPO = "yyn83/petclinic"         // 너 DockerHub Repo
        DOCKERHUB = credentials('dockerhub')    // DOCKERHUB_USR / DOCKERHUB_PSW 자동 생성
    }

    stages {

        stage('Checkout from GitHub') {
            steps {
                echo "📌 GitHub 소스코드 가져오는 중..."
                git url: "https://github.com/yuna83/spring-petclinic.git"
            }
        }

        stage('Build with Maven') {
            steps {
                echo "📌 Maven 빌드..."
                sh "chmod +x mvnw"
                sh "./mvnw clean package -DskipTests"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "📌 Docker 이미지 빌드..."
                sh """
                docker build -t ${DOCKER_REPO}:latest .
                """
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                echo "📌 DockerHub로 Push..."
                sh """
                echo "${DOCKERHUB_PSW}" | docker login -u "${DOCKERHUB_USR}" --password-stdin
                docker push ${DOCKER_REPO}:latest
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "📌 Kubernetes로 배포..."

                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KCFG')]) {
                    sh """
                    export KUBECONFIG=$KCFG
                    
                    # 최신 이미지로 Deployment 업데이트
                    kubectl set image deployment/petclinic petclinic=${DOCKER_REPO}:latest -n petclinic
                    
                    # 적용 확인
                    kubectl rollout status deployment/petclinic -n petclinic
                    """
                }
            }
        }
    }
}
