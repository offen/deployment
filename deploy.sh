#!/bin/bash

# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

set -eo pipefail

update_services () {
  docker-compose pull
  docker-compose build
  docker-compose up -d
  docker image prune -f
}

validate () {
  docker-compose config -q
}

check_deps () {
  local deps=("docker" "docker-compose")
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
validate
update_services
