#!/bin/bash

# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

set -eo pipefail

flags="-f docker-compose.yml"
for arg in "$@"; do
  flags="$flags -f docker-compose.${arg}.yml"
done

update_services () {
  docker-compose $flags pull
  docker-compose $flags build
  docker-compose $flags up -d
  docker image prune -f
}

validate_config () {
  docker-compose $flags config -q
}

check_deps () {
  local deps=("docker" "docker-compose")
  for dep in "${deps[@]}"; do
    if [ ! "$(command -v $dep)" ]; then
      echo "This script requires $dep, which is not installed. Cannot continue."
      exit 1
    fi
  done

  set +e
  docker info > /dev/null 2>&1; ec=$?
  set -e
  if [ "$ec" != "0" ]; then
    echo "Docker daemon not running, cannot continue."
    exit "$ec"
  fi
}

cd $(dirname $0)
check_deps
validate_config
update_services
