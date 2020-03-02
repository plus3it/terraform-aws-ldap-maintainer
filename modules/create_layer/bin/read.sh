#!/usr/bin/env bash

set +e
  contents=$(cat "$1")
set -e
# shellcheck disable=SC2086
echo '{"content": "'$contents'"}'

