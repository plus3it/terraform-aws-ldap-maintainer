#!/usr/bin/env bash

set -e

# set defaults
PYTHON_VERSION="python3.7"


get_target_dirs() {
  # create an array of all unique directories containing requirements.txt files
  # within this project
  PROJECT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )
  mapfile -t directories < <(find "$PROJECT_DIR" -name 'requirements.txt' -exec dirname {} \; | sort -u | grep -v "\.terraform\b\|\.terragrunt-cache\b")
}

build_image() {
  echo "$(tput setaf 2)=> building image from $DOCKERFILE$(tput sgr0)"
  docker build -t "$IMAGE_NAME" -f "$DOCKERFILE" .
}


docker_image_check() {
  # validate if the docker image is present on the host machine
  # if not found, create it
  IMAGE_NAME="${IMAGE_NAME:=ldapamaint/amazonlinux}"
  DOCKERFILE="Dockerfile.layers"

  IMAGE_ID=$(docker inspect --type=image -f '{{.Id}}' "$IMAGE_NAME" 2> /dev/null || true)
  if [ -z "$IMAGE_ID" ]; then
    echo "$(tput setaf 4) > image $IMAGE_NAME doesn't exist$(tput sgr0)"
    build_image
  else
    echo "$(tput setaf 4) > image $IMAGE_NAME already exists$(tput sgr0)"
  fi
}

get_docker_bindmount_dirs() {
  # create bindmount flags for each directory that requires a layer
  get_target_dirs

  CODE_DIR="/home/lambda_layer"
  DOCKER_BINDMOUNTS=()

  for dir in "${directories[@]}"
  do
    CONTAINER_DIR="$CODE_DIR/$(basename "${dir}")"
    DOCKER_BINDMOUNTS+=(-v "${dir}:$CONTAINER_DIR")
  done
}

docker_run() {
  # run docker
  docker_image_check
  get_docker_bindmount_dirs
  DOCKER_BINDMOUNTS+=(-v "$PROJECT_DIR/bin:$CODE_DIR/bin")

  docker run --rm -ti \
    "${DOCKER_BINDMOUNTS[@]}" \
    -w "$CODE_DIR" \
    --cap-add=SYS_PTRACE \
    "$IMAGE_NAME" bash -c './bin/generate-layer.sh -c'
}

create_layers() {
  get_target_dirs

  command -v zip > /dev/null 2>&1 || (echo "zip not available"; exit 1)
  command -v pip3 > /dev/null 2>&1 || (echo "pip3 not available"; exit 1)

  for dir in "${directories[@]}"
  do
    cd "${dir}" || ( echo "Unable to navigate to ${dir}"; exit 1)
    lambda_pacakge="/$(pwd)/lambda-package"
    layer_path="$lambda_pacakge/python/lib/$PYTHON_VERSION/site-packages/"
    mkdir -p "$layer_path" >/dev/null 2>&1 || ( echo "Unable to create $layer_path"; exit 1)
    pip3 install -r requirements.txt -t "$layer_path" >/dev/null 2>&1 || (echo "Encountered error installing python dependency"; exit 1)
    pushd lambda-package/ >/dev/null 2>&1 || ( echo "Unable to navigate to lambda-package/"; exit 1)
    zip -r ../lambda_layer_payload.zip python/* -x "setuptools*/*" "pkg_resources/*" "easy_install*" >/dev/null 2>&1
    popd >/dev/null 2>&1 || ( echo "Unable to return to source directory"; exit 1)
    rm -rf "$lambda_pacakge"
    echo "Generated layer for: $(basename "${dir}")"
  done
}

while getopts :rc opt
do
    case "${opt}" in
        r)
            # run docker
            docker_run
            ;;
        c)
            # create layers
            create_layers
            ;;
        \?)
            echo "ERROR: unknown parameter \"$OPTARG\""
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
