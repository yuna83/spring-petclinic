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
            steps {
                sh """
kubectl delete pod kaniko-builder -n jenkins --ignore-not-found=true

kubectl run kaniko-builder -n jenkins \
  --restart=Never \
  --image=gcr.io/kaniko-project/executor:debug \
  --overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [
      {
        "name": "kaniko",
        "image": "gcr.io/kaniko-project/executor:debug",
        "args": [
          "--dockerfile=Dockerfile",
          "--context=git://github.com/yuna83/spring-petclinic#main",
          "--destination=${DOCKER_REPO}:latest"
        ],
        "volumeMounts": [
          {
            "name": "docker-config",
            "mountPath": "/kaniko/.docker/"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "docker-config",
        "secret": {
          "secretName": "regcred",
          "items": [
            {
              "key": ".dockerconfigjson",
              "path": "config.json"
            }
          ]
        }
      }
    ]
  }
}
'
"""

                echo "Kaniko Pod started. Waiting for push..."
                sh "kubectl logs -f pod/kaniko-builder -n jenkins"
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
