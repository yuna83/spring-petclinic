pipeline {
    agent {
        kubernetes {
            label "test-light-ci"
            defaultContainer "jnlp"
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: test-light-ci
spec:
  serviceAccountName: jenkins

  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:slim
    command: ["cat"]
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker
    - name: kaniko-cache
      mountPath: /kaniko/.cache

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
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

    environment {
        DOCKER_REPO = "yyn83/test-light"
    }

    stages {

        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/test-light.git', branch: 'main'
                sh "echo '✔ Git Clone 완료'"
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
                      --cache=false
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh """
                    echo '✔ 배포 YAML 적용'
                    kubectl apply -f ${WORKSPACE}/k8s.yaml
                    echo '✔ 최신 이미지 적용'
                    kubectl set image deployment/test-app test-app=${DOCKER_REPO}:${BUILD_NUMBER} -n app
                    kubectl rollout status deployment/test-app -n app
                    """
                }
            }
        }
    }
}
