podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: jnlp
      image: jenkins/inbound-agent:latest-jdk17
      workingDir: /tmp/agent
      env:
        - { name: HOME, value: /tmp/agent }
    - name: nodejs
      image: node:20
      command: ["sleep"]
      args: ["infinity"]
      workingDir: /tmp/agent
      env:
        - { name: HOME, value: /tmp/agent }
''') {
  node(POD_LABEL) {
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
}
