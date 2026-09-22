node('nodejs') {
    stage('Checkout') {
        checkout scm
    }
    container('nodejs') {
        stage('Backend Tests') {
            sh 'node ./backend/test.js'
        }
        stage('Frontend Tests') {
            sh 'node ./frontend/test.js'
        }
    }
}
