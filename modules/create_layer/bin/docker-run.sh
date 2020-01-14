#!/usr/bin/env bash

set -e

function error_exit() {
    echo "$(tput setaf 4)$1$(tput sgr0)" 1>&2
    exit 1
}

function check_deps() {
    command -v docker > /dev/null 2>&1 || error_exit "docker not available"
}

function parse_input() {
    if [[ -z "${IMAGE_NAME}" ]]; then error_exit "Image name is required"; fi
}

function run_docker() {
    # strip the leading and trailing characters from the expected json encoded string
    DOCKER_BINDMOUNTS_STRING="${DOCKER_BINDMOUNTS:1:${#DOCKER_BINDMOUNTS}-2}"
    # split the bindmounts string into an array
    IFS=', ' read -r -a array <<< "$DOCKER_BINDMOUNTS_STRING"
    # create a new array for the bindmount elements to avoid double quoting
    DOCKER_BINDMOUNTS_ARRAY=()
    for element in "${array[@]}"
    do
        #remove the leading and trailing quotes that terraform adds to jsonencoded elements
        element="${element:1:${#element}-2}"
        DOCKER_BINDMOUNTS_ARRAY+=(-v "$element")
    done

    # shellcheck disable=SC2086
    # shellcheck disable=SC2068
    DOCKER_OUTPUTS=$(docker run --rm -i \
    ${DOCKER_BINDMOUNTS_ARRAY[@]} \
    -w "$BINDMOUNT_ROOT" \
    --cap-add=SYS_PTRACE \
    "$IMAGE_NAME" $LAYER_BUILD_COMMAND) || error_exit "Docker failed to run: $DOCKER_OUTPUTS"
}

# main()
check_deps
# echo "DEBUG: received: $INPUT" 1>&2
parse_input
run_docker
