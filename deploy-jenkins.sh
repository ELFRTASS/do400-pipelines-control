# Helm values for the official Jenkins chart (https://charts.jenkins.io)
# Tuned for OpenShift 4.x (restricted-v2 SCC: random UID, no fixed fsGroup)

controller:
  image:
    repository: jenkins/jenkins
    tag: lts-jdk17

  admin:
    username: admin
    # Leave empty to let the chart generate one (stored in secret "jenkins")
    password: ""

  # --- OpenShift: let the SCC assign UID / fsGroup instead of 1000 ---
  podSecurityContextOverride:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containerSecurityContext:
    runAsUser: null
    runAsGroup: null
    readOnlyRootFilesystem: true
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]

  # OpenShift runs with a random UID that has no home dir -> HOME=/ (read-only).
  # Point HOME / plugin cache to the writable Jenkins volume.
  initContainerEnv:
    - name: HOME
      value: /var/jenkins_home
    - name: CACHE_DIR
      value: /var/jenkins_home/.cache/jenkins-plugin-management-cli
  containerEnv:
    - name: HOME
      value: /var/jenkins_home

  resources:
    requests: { cpu: "250m", memory: "1Gi" }
    limits:   { cpu: "1",    memory: "2Gi" }   # sized for Developer Sandbox quota

  # Public URL of Jenkins = the OpenShift Route (update after deploy)
  jenkinsUrl: ""   # set automatically by deploy-jenkins.sh

  # Plugins on top of the chart defaults (kubernetes, workflow-aggregator, git, configuration-as-code)
  additionalPlugins:
    - pipeline-stage-view
    - pipeline-graph-view      # modern visual pipeline view (parallel + matrix graph)
    - openshift-client

  serviceType: ClusterIP

persistence:
  enabled: true
  size: 5Gi              # Sandbox storage quota is small
  # storageClass: gp3-csi     # uncomment to force a storage class

# --- Dynamic agents: each Jenkins node = a pod in the cluster ---
agent:
  enabled: true              # creates the "kubernetes" cloud in Jenkins
  namespace: null            # null = same namespace as Jenkins
  podRetention: Never        # delete the pod after the build
  idleMinutes: 0
  containerCap: 2            # max agent pods at the same time (Sandbox quota)
  resources:
    requests: { cpu: "100m", memory: "256Mi" }
    limits:   { cpu: "500m", memory: "512Mi" }
  runAsUser: null
  runAsGroup: null

  # Extra pod templates: a job asking for label "maven" or "nodejs" gets a pod with that tool
  podTemplates:
    maven: |
      - name: maven
        label: maven
        idleMinutes: 0
        containers:
          - name: maven
            image: maven:3.9-eclipse-temurin-17
            command: "sleep"
            args: "infinity"
            ttyEnabled: true
            resourceRequestCpu: "250m"
            resourceRequestMemory: "512Mi"
            resourceLimitCpu: "1"
            resourceLimitMemory: "1Gi"
            envVars:
              - envVar:
                  key: MAVEN_OPTS
                  value: "-Duser.home=/home/jenkins/agent"
    nodejs: |
      - name: nodejs
        label: nodejs
        idleMinutes: 0
        containers:
          - name: nodejs
            image: node:20
            command: "sleep"
            args: "infinity"
            ttyEnabled: true
            envVars:
              - envVar:
                  key: HOME
                  value: "/home/jenkins/agent"

# ServiceAccount + Role so Jenkins can create/delete agent pods
serviceAccount:
  create: true
  name: null        # null = same name as the Helm release (jenkins-k8s), avoids clashing with an existing "jenkins" SA
rbac:
  create: true
