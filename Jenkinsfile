pipeline {

    /***********************************************************
     * 👇 1. Jenkins Agent를 Kubernetes 위에 “임시 파드”로 생성하는 설정
     *    - Maven 빌드: jnlp 컨테이너 사용
     *    - Docker 이미지 빌드: kaniko 컨테이너 사용
     *    - K8s 배포: kubectl 컨테이너 사용
     ***********************************************************/
    agent {
        kubernetes {
            label 'petclinic-build'
            defaultContainer 'jnlp'

            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: petclinic-build
spec:
  serviceAccountName: jenkins

  # 👉 Jenkins Agent 파드를 반드시 node02 에서 실행
  #    (node01에서 Kaniko 이미지가 깨져서 pull 되었던 문제 해결)
  nodeSelector:
    kubernetes.io/hostname: k8s-node02

  containers:

  # =========================================================
  #  🔥 2. Kaniko 컨테이너 (Docker 없이 이미지 빌드용)
  # =========================================================
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug

    # 👉 /bin/sh 없음 → /busybox/sh 를 직접 사용해야 함
    command: ["/busybox/sh", "-c", "sleep infinity"]
    tty: true

    # 👉 Kaniko executor 실행하려면 root 권한 필요
    securityContext:
      runAsUser: 0
      privileged: true

    volumeMounts:
    # DockerHub 로그인 정보
    - name: docker-config
      mountPath: /kaniko/.docker

    # Kaniko 캐시 (속도 향상)
    - name: kaniko-cache
      mountPath: /kaniko/.cache


  # =========================================================
  #  🔥 3. kubectl 컨테이너 (Kubernetes 배포용)
  # =========================================================
  - name: kubectl
    image: bitnami/kubectl:latest

    # 계속 살아있도록 유지
    command: ["/bin/sh", "-c", "sleep infinity"]
    tty: true

    # 쿠버네티스 API 호출을 위해 root 권한 필요할 때가 있음
    securityContext:
      runAsUser: 0
      privileged: true

    # K8s 인증 정보 mount
    volumeMounts:
    - name: kubeconfig
      mountPath: /root/.kube
      readOnly: true


  # =========================================================
  #  🔥 4. 볼륨: DockerHub token, kubeconfig, kaniko-cache
  # =========================================================
  volumes:

  # DockerHub credential (docker login.json)
  - name: docker-config
    secret:
      secretName: dockertoken
      items:
        - key: .dockerconfigjson
          path: config.json

  # K8s 인증 정보
  - name: kubeconfig
    secret:
      secretName: jenkins-kubeconfig

  # Kaniko 캐시 경로 (워커 노드의 hostPath)
  - name: kaniko-cache
    hostPath:
      path: /data/kaniko-cache

"""
        }
    }

    /***********************************************************
     * 🔧 5. Jenkins 내부 도구 (Maven, Java)
     *     - jnlp 컨테이너에 자동 경로 등록됨
     ***********************************************************/
    tools {
        maven "M3"
        jdk   "JDK17"
    }

    /***********************************************************
     * 🔧 6. 환경 변수: DockerHub Repository 이름
     ***********************************************************/
    environment {
        DOCKER_REPO = "yyn83/spring-petclinic"
    }

    /***********************************************************
     * 🚀 7. CI/CD 파이프라인 단계
     ***********************************************************/
    stages {

        /***********************
         * ✔ 1단계: Git Clone
         ***********************/
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
                sh "echo '✔ Git Clone 완료'"
            }
        }

        /***********************
         * ✔ 2단계: Maven Build
         ***********************/
        stage('Maven Build') {
            steps {
                sh "mvn -Dmaven.test.failure.ignore=true clean package"
                sh "echo '✔ Maven Build 완료'"
            }
        }

        /***********************************************************
         * ✔ 3단계: Kaniko Build & Push
         *    Jenkins sh는 기본적으로 /bin/sh 을 실행 → 실패
         *    그래서 busybox/sh 로 직접 executor 실행
         ***********************************************************/
        stage('Kaniko Build & Push') {
            steps {
                container('kaniko') {
                    sh '''
                        /busybox/sh -c "
                            /kaniko/executor \
                                --context=$WORKSPACE \
                                --dockerfile=$WORKSPACE/Dockerfile \
                                --destination=$DOCKER_REPO:$BUILD_NUMBER \
                                --destination=$DOCKER_REPO:latest \
                                --cache=true
                        "
                    '''
                }
            }
        }

        /***********************************************************
         * ✔ 4단계: Kubernetes 배포 (롤링 업데이트)
         ***********************************************************/
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh """
                        echo '✔ 최신 이미지 배포 시작'
                        kubectl set image deployment/petclinic petclinic=${DOCKER_REPO}:${BUILD_NUMBER} -n app

                        echo '✔ 롤링 업데이트 대기'
                        kubectl rollout status deployment/petclinic -n app
                    """
                }
            }
        }
    }
}
