pipeline {
    agent {
        kubernetes {
            label "petclinic-build"
            defaultContainer "jnlp"
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
