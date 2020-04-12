#!/bin/bash

# @description Run end to end tests
#
# @example
#   run-e2e-tests
#
# @arg $1 Task: "brief", "help" or "exec"
#
# @exitcode The result of the shellckeck
#
# @stdout "Not implemented" message if the requested task is not implemented
#
function run-e2e-tests() {

    # Init
    local briefMessage
    local helpMessage

    briefMessage="Run end to end tests"
    helpMessage=$(cat <<EOF
Run end to end tests using jpl project tests and the 'beta' image

Related project: https://github.com/tpbtools/jenkins-pipeline-library
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
            EXITCODE=0
            TESTDIR=$(mktemp -d)
            cd "${TESTDIR}" || exit 1
            git clone https://github.com/tpbtools/jenkins-pipeline-library.git -b develop
            cd jenkins-pipeline-library || exit 1
            TAG=beta bin/test.sh
            EXITCODE=$?
            rm -rf "${TESTDIR}"
            exit ${EXITCODE}
            ;;
        *)
            showNotImplemtedMessage "$1" "${FUNCNAME[0]}"
            return 1
    esac
}

# Main
run-e2e-tests "$@"