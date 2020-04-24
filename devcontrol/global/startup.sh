#!/bin/bash

# @file devcontrol/global/startup.sh
# @brief devcontrol startup script and functions
echo "Jenkins DinD (c) 2020 Ayuda Digital"
echo

# @description Check presence of docker-related pieces in the system
# The function aborts the execution if the system dont have docker installed
#
# @example
#   checkDocker
#
# @noargs
#
# @exitcode 0  If docker exist, abort execution if other case and return 1 to the system
#
# @stdout Show "Docker not present. Exiting -" message if missing docker
#
function checkDocker() {
    command -v docker > /dev/null 2>&1 || bash -c 'echo "Missing docker: aborting"; exit  1'
}
export -f checkDocker
