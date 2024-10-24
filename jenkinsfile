pipeline {
   agent { label 'nix' }

    triggers {
        pollSCM('H/1 * * * *')
    }

   stages {
       stage('Check') {
           steps {
               echo checking
               sh 'nix check --no-build'
           }
       }
   }
 }

