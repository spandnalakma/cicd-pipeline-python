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
                withCredentials([usernamePassword(credentialsId: 'kubeServer', usernameVariable: 'USERNAME', passwordVariable: 'USERPASS')]) {
                    sshPublisher(
                        failOnError: true,
                        continueOnError: false,
                        publishers: [
                            sshPublisherDesc(
                                configName: 'kubernates',
                                sshCredentials: [
                                    username: "$USERNAME",
                                    encryptedPassphrase: "$USERPASS"
                                ],
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: 'kube-deployment.yml',
                                        remoteDirectory: '/',
                                        execCommand: 'sudo cat /etc/hostname'
                                    )
                                ]
                            )
                        ]
                    )
                }
            }
        }
   }
    post {
         always {
             echo 'One way or another, I have finished'
             deleteDir() /* clean up our workspace */
         }
    }
}