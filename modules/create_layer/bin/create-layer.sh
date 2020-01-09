#!/usr/bin/env bash

set -e

function error_exit() {
    echo "$(tput setaf 4)$1$(tput sgr0)" 1>&2
    exit 1
}

PYTHON_VERSION="python3.7"

# Ensure required bins were installed
command -v zip > /dev/null 2>&1 || (echo "zip not available"; exit 1)
command -v pip3 > /dev/null 2>&1 || (echo "pip3 not available"; exit 1)

PROJECT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )
mapfile -t directories < <(find "$PROJECT_DIR" -name 'requirements.layer.txt' -exec dirname {} \; | sort -u | grep -v "\.terraform\b\|\.terragrunt-cache\b")

for dir in "${directories[@]}"
do
  cd "${dir}" || error_exit "Unable to navigate to ${dir}"
  lambda_package="/$(pwd)/lambda-package"
  layer_path="$lambda_package/python/lib/$PYTHON_VERSION/site-packages/"
  mkdir -p "$layer_path" || error_exit "Unable to create $layer_path"
  pip3 install -r requirements.layer.txt -t "$layer_path" || error_exit "Encountered error installing python dependency"
  pushd lambda-package/ || error_exit "Unable to navigate to lambda-package/"
  zip -r ../lambda_layer_payload.zip python/* -x "setuptools*/*" "pkg_resources/*" "easy_install*" >/dev/null 2>&1 || error_exit "encountered error when compressing archive"
  popd || error_exit "Unable to return to source directory"
  rm -rf "$lambda_package"
done
