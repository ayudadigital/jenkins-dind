#!/bin/bash

set -euo pipefail

# @description Build the ayudadigital/jenkins-dind docker image
#
# @example
#   build
#
# @arg $1 Task: "brief", "help" or "exec"
#
# @exitcode The exit code of the statements of the action
#
# @stdout "Not implemented" message if the requested task is not implemented
#
function build() {

    # Init
    local briefMessage
    local helpMessage
    briefMessage="Build the ayudadigital/jenkins-dind docker image"
    helpMessage=$(cat <<EOF
Build the Jenkins Dind image.
It is based in a combination of jenkins/jenkins:lts docker image and docker:dind
EOF
)

    # Task choosing
    case $1 in
        brief)
            showBriefMessage "${FUNCNAME[0]}" "$briefMessage"
            ;;
        help)
            showHelpMessage "${FUNCNAME[0]}" "$helpMessage"
            ;;
        exec)
            checkDocker
            # Get jenkins version
            source jenkins-version.ini
            if [ "$2" == "beta" ]; then
                JENKINS_TAG="beta"
            else
                JENKINS_TAG=${JENKINS_VERSION}
            fi
            # Prepare build directory
            baseDir="$(pwd)"
            buildDir="$(mktemp -d)"
            cd "${buildDir}"
            git clone --quiet https://github.com/jenkinsci/docker.git .
            rsync -a "${baseDir}/resources/" resources/
            # Make "frankenstein" ayudadigital/jenkins-dind Dockerfile
            echo "FROM docker:dind" > Dockerfile-jenkins-dind
            cat resources/Dockerfile.partial >> Dockerfile-jenkins-dind
            grep -v "^FROM\|^ENTRYPOINT" Dockerfile-alpine >> Dockerfile-jenkins-dind
            echo "USER root" >> Dockerfile-jenkins-dind
            # Build the ayudadigital/jenkins-dind docker image
            docker build --pull --no-cache --build-arg JENKINS_VERSION="${JENKINS_VERSION}" --build-arg JENKINS_SHA="${JENKINS_SHA}" --file Dockerfile-jenkins-dind -t ayudadigital/jenkins-dind:"${JENKINS_TAG}" .
            if [ ${JENKINS_TAG} != "beta" ]; then
                docker tag ayudadigital/jenkins-dind:"${JENKINS_TAG}" ayudadigital/jenkins-dind:latest
            fi
            # Prune build dir
            cd "${baseDir}" || exit 1
            rm -rf "${buildDir}"
            ;;
        *)
            showNotImplemtedMessage "$1" "${FUNCNAME[0]}"
            return 1
    esac
}

# Main
build "$@"