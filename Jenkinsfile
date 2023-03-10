pipeline{
   agent any
   environment{
     DOCKER_IMAGE_NAME="spandanalakma/python_flask"
   }
   stages{
     stage('Build Docker Image'){
        when{
           branch 'master'
        }
       steps{
           script{
             app = docker.build(DOCKER_IMAGE_NAME)
//              app.inside{
//                  sh "echo ${curl localhost:5000}"
//              }
           }
       }
     }
     stage('Publish Docker Image'){
        when{
           branch 'master'
        }
        steps{
           script{
             docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login'){
             app.push("${env.BUILD_NUMBER}")
             app.push("latest")
             }
           }
        }
     }
      stage('Deploy To Production') {
            when {
                branch 'master'
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                sh """
                  ls -lrt
                  chmod +x kube-deployment.yml
                """
                withCredentials([usernamePassword(credentialsId: 'kubeServer', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                    sshPublisher(
                        failOnError: true,
                        continueOnError: false,
                        publishers: [
                            sshPublisherDesc(
                                configName: 'kubernates',
                                verbose: true,
                                sshCredentials: [
                                    username: "$USERNAME",
                                    encryptedPassphrase: "$USERPASS"
                                ],
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: 'kube-deployment.yml',
                                        remoteDirectory: '/',
                                        execCommand: 'kubectl apply -f /tmp/kube-deployment.yml && rm /tmp/train-schedule-kube.yml'
                                    )
                                ]
                            )
                        ]
                    )
                }
            }
        }
   }
}