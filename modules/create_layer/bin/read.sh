#!/usr/bin/env bash

set +e
  contents=$(cat $1)
set -e
echo '{"content": "'$contents'"}'

