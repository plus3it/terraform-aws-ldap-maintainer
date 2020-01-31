#!/usr/bin/env bash

set -e

function error_exit() {
    echo "$(tput setaf 4)$1$(tput sgr0)" 1>&2
    exit 1
}

function parse_input() {
    # jq reads from stdin so we don't have to set up any inputs, but let's validate the outputs
    # eval "$(jq -r '@sh "export LAYER_NAME=\(.layer_name)
    # LAYER_DESCRIPTION=\(.layer_description)
    # COMPATIBLE_RUNTIMES=\(.compatible_runtimes)
    # LAYER_ARCHIVE_NAME=\(.layer_archive_name)
    # LAYER_ARCHIVE_PATH=\(.layer_archive_path)"')"
    if [[ -z "${LAYER_NAME}" ]]; then error_exit "layer_name is required"; fi
    if [[ -z "${LAYER_ARCHIVE_NAME}" ]]; then error_exit "layer_archive_name is required"; fi
    if [[ -z "${TARGET_LAMBDA_PATH}" ]]; then error_exit "target_layer_path is required"; fi
    if [[ -z "${COMPATIBLE_RUNTIMES}" ]]; then error_exit "compatible_runtimes are required"; fi
    if [[ -z "${LAYER_NAME}" ]]; then error_exit "layer_name is required"; fi
}

function publish_layer() {
  LAYER_ARCHIVE_FULL_PATH=$TARGET_LAMBDA_PATH/$LAYER_ARCHIVE_NAME

  PUBLISH_LAYER_RESPONSE=$(aws lambda publish-layer-version \
      --layer-name "$LAYER_NAME" \
      --description "$LAYER_DESCRIPTION" \
      --zip-file "fileb://$LAYER_ARCHIVE_FULL_PATH" \
      --compatible-runtimes "$COMPATIBLE_RUNTIMES") || error_exit "failed to publish layer"

  LAYER_ARN=$(echo "$PUBLISH_LAYER_RESPONSE" | jq -r '.LayerVersionArn')
}

function produce_output() {
    # jq -n \
    #     --arg layer_arn "$LAYER_ARN" \
    #     '{"layer_arn":$layer_arn}'
    echo "$LAYER_ARN"
}

# main()
parse_input
publish_layer
produce_output
