pipeline {
    agent {
        kubernetes {
            inheritFrom 'nodejs'        // our "nodejs" template (Helm)
            defaultContainer 'nodejs'   // every sh step runs in the node:20 container
        }
    }

    parameters {
        booleanParam(name: 'RUN_FRONTEND_TESTS', defaultValue: true, description: 'Run the frontend tests?')
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
                    when { expression { params.RUN_FRONTEND_TESTS } }
                    steps {
                        sh 'node ./frontend/test.js'
                    }
                }
            }
        }
        stage('Deploy') {
            when {
                expression { env.GIT_BRANCH == 'origin/main' }
                beforeInput true
            }
            input {
                message 'Deploy the application?'
            }
            steps {
                echo 'Deploying...'
            }
        }
    }
}
