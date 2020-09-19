#!/usr/bin/env sh

set -eo pipefail

limit=${1:-7}
PATH="$PATH:/usr/local/bin"

export MC_HOST_offen="https://${AWS_ACCESS_KEY_ID}:${AWS_SECRET_ACCESS_KEY}@storage.offen.dev"

backup_count=$(mc ls offen/db-backups | wc -l)
if [ "$backup_count" -le "$limit" ]; then
  echo "Backup bucket contains ${backup_count} item(s) only, skipping because a limit of ${limit} was set"
  exit 0
fi

mc rm --recursive --force --older-than 7d offen/db-backups
echo "Successfully expired all backups older than 7 days"
