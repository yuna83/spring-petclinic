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

            // ⭐ Kaniko 전용 PodTemplate 사용
            //   (Jenkins agent jnlp 방식 X)
            agent {
                kubernetes {
                    yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug

    # ⭐ Kaniko 실행 명령 (jnlp 없음)
    command:
      - /kaniko/executor

    # ⭐ context 경로 수정됨
    #   Jenkins workspace → /workspace/<JOB_NAME>
    #   (이전 값 /workspace 는 비어 있어서 실패했던 원인)
    args:
      - "--dockerfile=Dockerfile"
      - "--context=/workspace/${JOB_NAME}"
      - "--destination=${DOCKER_REPO}:latest"

    volumeMounts:
      # ⭐ DockerHub 인증 정보 mount
      - name: docker-config
        mountPath: /kaniko/.docker/

      # ⭐ Kaniko가 소스코드를 읽을 실제 workspace mount
      #   (이게 없으면 Kaniko는 Dockerfile 자체를 못 찾음)
      - name: workspace-volume
        mountPath: /workspace

  restartPolicy: Never

  volumes:

  # ⭐ DockerHub secret
  - name: docker-config
    secret:
      secretName: regcred
      items:
      - key: .dockerconfigjson
        path: config.json

  # ⭐ Jenkins workspace 를 Kaniko로 전달할 빈 디렉토리 생성
  #   Jenkins에서 cp -a 로 내용을 넣어줄 것
  - name: workspace-volume
    emptyDir: {}
"""
                }
            }

            steps {

                // ⭐ Jenkins workspace → Kaniko workspace 복사
                //   Kaniko는 Pod 내부의 /workspace/<JOB_NAME>만 읽기 때문에,
                //   Jenkins의 실제 workspace 내용을 복사해줘야 정상 빌드 가능.
                sh """
                echo "Copying Jenkins workspace to Kaniko workspace..."
                mkdir -p /workspace/${env.JOB_NAME}
                cp -a * /workspace/${env.JOB_NAME}/
                """

                echo "Kaniko Build Starting"
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
