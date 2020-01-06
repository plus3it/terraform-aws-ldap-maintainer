#!/usr/bin/env bash

set -e

PYTHON_VERSION="python3.7"

# Ensure required bins were installed
command -v zip > /dev/null 2>&1 || (echo "zip not available"; exit 1)
command -v pip3 > /dev/null 2>&1 || (echo "pip3 not available"; exit 1)

PROJECT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )"/.. >/dev/null 2>&1 && pwd )
mapfile -t directories < <(find "$PROJECT_DIR" -name 'requirements.layer.txt' -exec dirname {} \; | sort -u | grep -v "\.terraform\b\|\.terragrunt-cache\b")

for dir in "${directories[@]}"
do
  cd "${dir}" || ( echo "Unable to navigate to ${dir}"; exit 1)
  lambda_package="/$(pwd)/lambda-package"
  layer_path="$lambda_package/python/lib/$PYTHON_VERSION/site-packages/"
  mkdir -p "$layer_path" || ( echo "Unable to create $layer_path"; exit 1)
  pip3 install -r requirements.layer.txt -t "$layer_path" || (echo "Encountered error installing python dependency"; exit 1)
  pushd lambda-package/ || ( echo "Unable to navigate to lambda-package/"; exit 1)
  zip -r ../lambda_layer_payload.zip python/* -x "setuptools*/*" "pkg_resources/*" "easy_install*" >/dev/null 2>&1
  popd || ( echo "Unable to return to source directory"; exit 1)
  rm -rf "$lambda_package"
  echo "Generated layer for: $(basename "${dir}")"
done
