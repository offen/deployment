#!/usr/bin/env sh

# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

set -e

bucket=$1
limit=${2:-7}

PATH="$PATH:/usr/local/bin"

export MC_HOST_backups="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}@${AWS_ENDPOINT}"

backup_count=$(mc ls "backups/$bucket" | wc -l)
if [ "$backup_count" -le "$limit" ]; then
  echo "Backup bucket ${bucket} contains ${backup_count} item(s) only, skipping because a limit of ${limit} was set"
  exit 0
fi

mc rm --recursive --force --older-than "${limit}d" "backups/$bucket"
echo "Successfully expired all backups older than ${limit} days"
