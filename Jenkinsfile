pipeline {
    agent any

    tools {
        maven "M3"
        jdk "JDK17"
    }

    environment {
        DOCKERHUB = credentials('dockerCredentials')
    }

    stages {

        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
            }
        }

        stage('Maven Build') {
            steps {
                sh "mvn -Dmaven.test.failure.ignore=true clean package"
            }
        }

        stage('Build & Push Image on Master Node') {
            steps {
                sshagent(credentials: ['k8s-master-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@192.168.20.101 "
                            set -e

                            echo '▶️ 1. petclinic 작업 폴더 준비'
                            mkdir -p /home/ubuntu/petclinic
                            cd /home/ubuntu/petclinic

                            echo '▶️ 2. Jenkins에서 빌드한 JAR 복사'
                            rm -f app.jar
                            cp ${WORKSPACE}/target/*petclinic*.jar ./app.jar

                            echo '▶️ 3. DockerHub 로그인'
                            echo '${DOCKERHUB_PSW}' | docker login -u '${DOCKERHUB_USR}' --password-stdin

                            echo '▶️ 4. Docker 이미지 빌드'
                            docker build -t yyn83/spring-petclinic:${BUILD_NUMBER} .

                            echo '▶️ 5. 이미지 Push'
                            docker push yyn83/spring-petclinic:${BUILD_NUMBER}

                            echo '▶️ 6. latest 태그 Push'
                            docker tag yyn83/spring-petclinic:${BUILD_NUMBER} yyn83/spring-petclinic:latest
                            docker push yyn83/spring-petclinic:latest
                        "
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sshagent(credentials: ['k8s-master-ssh']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@192.168.20.101 "
                            echo '▶️ Kubernetes 배포 시작'
                            kubectl set image deployment/petclinic petclinic=yyn83/spring-petclinic:${BUILD_NUMBER} -n default
                            kubectl rollout status deployment/petclinic -n default
                        "
                    '''
                }
            }
        }
    }
}
