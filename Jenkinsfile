node('nodejs') {
    stage('Checkout') {
        git branch: 'main',
            url: 'https://github.com/ELFRTASS/do400-pipelines-control'
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
