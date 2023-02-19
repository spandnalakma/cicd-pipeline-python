pipeline{
   agent any
   stages{
     stage('Build Docker Image'){
        when{
           branch 'master'
        }
       steps{
           script{
             app = docker.build("spandanalakma/python_flask")
             app.inside{
                 sh 'echo ${curl localhost:5000}'
             }
           }
       }
     }
     stage('Publish Docker Image'){
        when{
           branch 'master'
        }
        steps{
           script{
             app=docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login')
             app.push("${env.BUILD_NUMBER}")
             app.push("latest")
           }
        }
     }
     stage("Deploy to Production"){
       when{
         branch 'master'
       }
       steps{
         input 'Deploy to Production?'
         milestone(1)
         sh'''
         #/bin/bash
         docker pull spandanalakma/python_flask:${env.BUILD_NUMBER}
         docker run --restart always -n python-app -p 5000:5000 -d spandanalakma/python_flask:${env.BUILD_NUMBER}
         '''
       }
     }
   }
}