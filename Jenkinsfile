#!groovy

@Library('github.com/ayudadigital/jenkins-pipeline-library@v4.0.0') _

// Initialize global config
cfg = jplConfig('jenkins-dind', 'docker', '', [email: env.CI_NOTIFY_EMAIL_TARGETS])
String jenkinsVersion

/**
 * Publish docker image
 *
 * @param nextReleaseNumber String Release number to be used as tag
 */
def publishDockerImage(String jenkinsVersion) {
    docker.withRegistry("", 'docker-token') {
        docker.image("${env.DOCKER_ORGANIZATION}/jenkins-dind:${jenkinsVersion}").push()
        if (jenkinsVersion != "beta") {
            docker.image("${env.DOCKER_ORGANIZATION}/jenkins-dind:latest").push()
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
                sh "devcontrol run-bash-linter"
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
        cleanup {
            deleteDir()
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 10, unit: 'MINUTES')
    }
}
