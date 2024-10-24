pipeline {
   agent none

    triggers {
        pollSCM('H/5 * * * *')
    }

   stages {
       stage('Check') {
           agent { label 'nix' }
           steps {
               sh 'nix check --no-build'
           }
       }
   }
 }

