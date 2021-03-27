#!/bin/sh

# Copyright 2020 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

set -e

source /root/env.sh

bucket=$AWS_S3_BUCKET
limit=$EXPIRE_RETENTION

backup_count=$(mc ls "backup-target/$bucket" | wc -l)
if [ "$backup_count" -le "$limit" ]; then
  echo "Backup bucket ${bucket} contains ${backup_count} item(s) only, skipping because a limit of ${limit} was set"
  exit 0
fi

mc rm --recursive --force --older-than "${limit}d" "backup-target/$bucket"
echo "Successfully expired all backups older than ${limit} days"
