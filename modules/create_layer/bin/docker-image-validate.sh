#!/usr/bin/env bash

# validate if the docker image is present on the host machine
# if not found, create it

set -e

command -v docker > /dev/null 2>&1 || ( echo "$(tput setaf 4)docker not available$(tput sgr0)"; exit 1)

IMAGE_ID=$(docker inspect --type=image -f '{{.Id}}' "$IMAGE_NAME" 2> /dev/null || true)
if [ -z "$IMAGE_ID" ]; then
  echo "$(tput setaf 4) > image $IMAGE_NAME doesn't exist$(tput sgr0)"
  # build the image
  echo "$(tput setaf 2) > building image from $DOCKERFILE$(tput sgr0)"
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .
else
  echo "$(tput setaf 4) > image $IMAGE_NAME already exists$(tput sgr0)"
fi
