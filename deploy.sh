#!/bin/bash

# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

set -eo pipefail

prepare () {
  for file in "$@"; do
    aws --profile storage --endpoint-url https://storage.offen.dev s3 cp $file .
  done
}

update_services () {
  docker-compose pull
  docker-compose build
  docker-compose up -d
}

cleanup () {
  # this makes sure we do not keep old image layers
  docker image prune -f
}

check_deps () {
  local deps=("aws" "docker" "docker-compose")
  for dep in "${deps[@]}"; do
    if [ ! -x "$(which $dep)" ]; then
      echo "This script requires $dep, which is not installed. Cannot continue."
      exit 1
    fi
  done

  set +e
  docker info > /dev/null 2>&1; ec=$?
  set -e
  if [ "$ec" != "0" ]; then
    echo "Docker daemon not running, cannot continue."
    exit 1
  fi
}

cd $(dirname $0)
check_deps
prepare "$@"
update_services
cleanup
