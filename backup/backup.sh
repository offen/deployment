#!/bin/sh

# Copyright 2021 - Offen Authors <hioffen@posteo.de>
# SPDX-License-Identifier: MIT

# Portions of this file are taken from github.com/futurice/docker-volume-backup
# See NOTICE for information about authors and licensing.

source env.sh

function info {
  bold="\033[1m"
  reset="\033[0m"
  echo -e "\n$bold[INFO] $1$reset\n"
}

info "Backup starting"
DOCKER_SOCK="/var/run/docker.sock"

if [ -S "$DOCKER_SOCK" ]; then
  TEMPFILE="$(mktemp)"
  docker ps \
    --format "{{.ID}}" \
    --filter "label=offen.stop-during-backup=true" \
    > "$TEMPFILE"
  CONTAINERS_TO_STOP="$(cat $TEMPFILE | tr '\n' ' ')"
  CONTAINERS_TO_STOP_TOTAL="$(cat $TEMPFILE | wc -l)"
  CONTAINERS_TOTAL="$(docker ps --format "{{.ID}}" | wc -l)"
  rm "$TEMPFILE"
  echo "$CONTAINERS_TOTAL containers running on host in total"
  echo "$CONTAINERS_TO_STOP_TOTAL containers marked to be stopped during backup"
else
  CONTAINERS_TO_STOP_TOTAL="0"
  CONTAINERS_TOTAL="0"
  echo "Cannot access \"$DOCKER_SOCK\", won't look for containers to stop"
fi

if [ "$CONTAINERS_TO_STOP_TOTAL" != "0" ]; then
  info "Stopping containers"
  docker stop $CONTAINERS_TO_STOP
fi

info "Creating backup"
BACKUP_FILENAME="$(date +"${BACKUP_FILENAME:-backup-%Y-%m-%dT%H-%M-%S.tar.gz}")"
tar -czvf "$BACKUP_FILENAME" $BACKUP_SOURCES # allow the var to expand, in case we have multiple sources

if [ ! -z "$GPG_PASSPHRASE" ]; then
  info "Encrypting backup"
  gpg --symmetric --cipher-algo aes256 --batch --passphrase "$GPG_PASSPHRASE" \
    -o "${BACKUP_FILENAME}.gpg" $BACKUP_FILENAME
  rm $BACKUP_FILENAME
  BACKUP_FILENAME="${BACKUP_FILENAME}.gpg"
fi

if [ "$CONTAINERS_TO_STOP_TOTAL" != "0" ]; then
  info "Starting containers back up"
  docker start $CONTAINERS_TO_STOP
fi

if [ ! -z "$AWS_S3_BUCKET_NAME" ]; then
  info "Uploading backup to S3"
  echo "Will upload to bucket \"$AWS_S3_BUCKET_NAME\""
  mc cp "$BACKUP_FILENAME" "backup-target/$AWS_S3_BUCKET_NAME"
  echo "Upload finished"
fi

if [ -f "$BACKUP_FILENAME" ]; then
  info "Cleaning up"
  rm -vf "$BACKUP_FILENAME"
fi

info "Backup finished"
echo "Will wait for next scheduled backup"

if [ ! -z "$BACKUP_RETENTION_DAYS" ]; then
  info "Pruning old backups"
  bucket=$AWS_S3_BUCKET_NAME

  rule_applies_to=$(mc rm --fake --recursive -force --older-than "${BACKUP_RETENTION_DAYS}d" "backup-target/$bucket" | wc -l)
  available=$(mc ls "backup-target/$bucket" | wc -l)

  if [ "$rule_applies_to" == "$available" ]; then
    echo "Using a retention of $BACKUP_RETENTION_DAYS days would prune all existing backups, will not continue."
    echo "If this is what you want, please remove files manually instead of using this script."
    exit 1
  fi

  mc rm --recursive -force --older-than "${BACKUP_RETENTION_DAYS}d" "backup-target/$bucket"
  echo "Successfully pruned all backups older than ${BACKUP_RETENTION_DAYS} days"
fi
