pipeline {

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

  containers:

  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/sh", "-c", "sleep infinity"]
    tty: true
    securityContext:
      runAsUser: 0
      privileged: true
    shell: ["/busybox/sh"]
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: kaniko-cache
      mountPath: /kaniko/.cache

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["/bin/sh", "-c", "sleep infinity"]
    tty: true
    securityContext:
      runAsUser: 0
      privileged: true
    volumeMounts:
    - name: kubeconfig
      mountPath: /root/.kube
      readOnly: true

  volumes:

  - name: docker-config
    secret:
      secretName: dockertoken
      items:
        - key: .dockerconfigjson
          path: config.json

  - name: kubeconfig
    secret:
      secretName: jenkins-kubeconfig

  - name: kaniko-cache
    hostPath:
      path: /data/kaniko-cache
"""
        }
    }

    tools {
        maven "M3"
        jdk   "JDK17"
    }

    environment {
        DOCKER_REPO = "yyn83/spring-petclinic"
    }

    stages {

        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
                sh "echo '✔ Git Clone 완료'"
            }
        }

        stage('Maven Build') {
            steps {
                sh "mvn -Dmaven.test.failure.ignore=true clean package"
                sh "echo '✔ Maven Build 완료'"
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
                        echo '✔ 최신 이미지 배포 시작'
                        kubectl set image deployment/petclinic petclinic=${DOCKER_REPO}:${BUILD_NUMBER} -n app

                        echo '✔ 롤링 업데이트 완료 대기'
                        kubectl rollout status deployment/petclinic -n app
                    """
                }
            }
        }
    }
}
