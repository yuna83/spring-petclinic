pipeline {
    agent any

    stages {
        stage('Print Docker Version') {
            steps {
                sh '''
                    echo "==== Check docker CLI ===="
                    docker --version || true
                '''
            }
        }

        stage('Try Docker Build') {
            steps {
                sh '''
                    echo "==== Try to Docker Build ===="
                    
                    # 테스트용 Dockerfile 만들기
                    echo "FROM alpine" > Dockerfile

                    # 도커 빌드 시도
                    docker build -t test-image:latest .
                '''
            }
        }
    }
}
