#!/usr/bin/env bash

set -e

command -v docker > /dev/null 2>&1 || ( echo "$(tput setaf 4)docker not available$(tput sgr0)"; exit 1)

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

# disable var quotation shellcheck on $LAYER_BUILD_COMMAND
# since terraform already quote wraps the string
# shellcheck disable=SC2086
docker run --rm -i \
  "${DOCKER_BINDMOUNTS_ARRAY[@]}" \
  -w "$BINDMOUNT_ROOT" \
  --cap-add=SYS_PTRACE \
  "$IMAGE_NAME" $LAYER_BUILD_COMMAND
