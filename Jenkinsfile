#!groovy

@Library('github.com/teecke/jenkins-pipeline-library@v3.4.1') _

// Initialize global config
cfg = jplConfig('jenkins-dind', 'docker', '', [email: env.CITEECKE_NOTIFY_EMAIL_TARGETS])
String jenkinsVersion

def publishDockerImage(String jenkinsVersion) {
    docker.withRegistry("https://registry.hub.docker.com", 'teeckebot-docker-credentials') {
        docker.image("teecke/jenkins-dind:${jenkinsVersion}").push()
        if (jenkinsVersion != "beta") {
            docker.image("teecke/jenkins-dind:latest").push()
        }

    }
}

pipeline {
    agent { label 'docker' }

    stages {
        stage ('Initialize') {
            steps  {
                jplStart(cfg)
                script {
                    jenkinsVersion = sh (script: 'cat jenkins-version.ini|grep JENKINS_VERSION|cut -f 2 -d "="', returnStdout: true).trim()
                }
            }
        }
        stage ('Bash linter') {
            steps {
                script {
                    sh "devcontrol run-bash-linter"
                }
            }
        }
        stage ('Build') {
            steps {
                script {
                    sh "devcontrol build"
                    sh "devcontrol build beta"
                }
            }
        }
        stage ('Publish beta') {
            when { anyOf { branch 'develop'; branch 'release/new' } }
            steps {
                publishDockerImage('beta')
            }
        }
        stage ('Run E2E tests') {
            when { anyOf { branch 'develop'; branch 'release/new' } }
            steps {
                sh "devcontrol run-e2e-tests"
            }
        }
        stage('Make release') {
            when { expression { cfg.BRANCH_NAME.startsWith('release/new') } }
            steps {
                publishDockerImage(jenkinsVersion)
                jplMakeRelease(cfg, true)
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }
}
