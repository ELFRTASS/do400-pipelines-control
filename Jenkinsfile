pipeline {
    agent {
        kubernetes {
            inheritFrom 'nodejs'        // our "nodejs" template (Helm)
            defaultContainer 'nodejs'   // every sh step runs in the node:20 container
        }
    }
    stages {
        stage('Run Tests') {
            parallel {
                stage('Backend Tests') {
                    steps {
                        sh 'node ./backend/test.js'
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        sh 'node ./frontend/test.js'
                    }
                }
            }
        }
    }
}
