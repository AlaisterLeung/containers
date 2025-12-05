#!/bin/bash
set -e

if [ -z "$1" ] || { [ "$1" != "local" ] && [ "$1" != "remote" ]; }; then
    echo "Usage: $0 <local|remote>"
    exit 1
fi

BACKUP_TYPE="$1"
shift

podman run --rm -it \
    --env-file "/etc/atxoft/backup/$BACKUP_TYPE.env" \
    -v restic-cache:/root/.cache/restic \
    -v /var/backup/containers:/backup:z \
    docker.io/restic/restic:latest "$@"
