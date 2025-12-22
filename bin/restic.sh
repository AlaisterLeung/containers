#!/bin/bash
set -e

if [ -z "$1" ] || { [ "$1" != "local" ] && [ "$1" != "remote" ]; }; then
    echo "Usage: $0 <local|remote>"
    exit 1
fi

BACKUP_TYPE="$1"
shift

podman run --rm -i \
    -h atxoft \
    --env-file "/etc/atxoft/backup/$BACKUP_TYPE.env" \
    -v restic-cache:/.cache/restic \
    -v /var/backup/containers:/backup:z \
    --userns "keep-id:uid=$(id -u pod_user),gid=$(id -g pod_user)" \
    docker.io/restic/restic:latest "$@"
