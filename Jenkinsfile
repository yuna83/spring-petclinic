pipeline {

    agent {
        kubernetes {
            label 'petclinic-build'
            defaultContainer 'jnlp'

            yaml """
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins
  nodeSelector:
    kubernetes.io/hostname: k8s-node02

  containers:

  # -----------------------------
  # Maven Container (빌드 전용)
  # -----------------------------
  - name: maven
    image: maven:3-openjdk-17
    command: ["/bin/sh", "-c", "sleep infinity"]
    tty: true

  # -----------------------------
  # Kaniko Container (이미지 빌드)
  # -----------------------------
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    command: ["/busybox/sh", "-c", "sleep infinity"]
    tty: true
    securityContext:
      runAsUser: 0
      privileged: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
      - name: kaniko-cache
        mountPath: /kaniko/.cache

  # -----------------------------
  # Kubectl Container (배포)
  # -----------------------------
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

  # -----------------------------
  # Volumes
  # -----------------------------
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
        DOCKER_REPO = "yyn83/spring-petclinic"
    }

    stages {

        # =============================
        # Git Clone
        # =============================
        stage('Git Clone') {
            steps {
                git url: 'https://github.com/yuna83/spring-petclinic.git', branch: 'main'
            }
        }

        # =============================
        # Maven Build
        # =============================
        stage('Maven Build') {
            steps {
                container('maven') {
                    sh "mvn clean package -DskipTests"
                }
            }
        }

        # =============================
        # Kaniko Build & Push
        # =============================
        stage('Kaniko Build & Push') {
            steps {
                container('kaniko') {
                    sh '''#!/busybox/sh
                        /kaniko/executor \
                          --context=$WORKSPACE \
                          --dockerfile=$WORKSPACE/Dockerfile \
                          --destination=$DOCKER_REPO:$BUILD_NUMBER \
                          --destination=$DOCKER_REPO:latest \
                          --cache=true
                    '''
                }
            }
        }

        # =============================
        # Deploy to Kubernetes
        # =============================
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        kubectl set image deployment/petclinic petclinic=$DOCKER_REPO:$BUILD_NUMBER -n app
                        kubectl rollout status deployment/petclinic -n app
                    '''
                }
            }
        }
    }
}
