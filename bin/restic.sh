#!/bin/bash
set -e

if [ -z "$1" ] || { [ "$1" != "local" ] && [ "$1" != "remote" ]; }; then
    echo "Usage: $0 <local|remote>"
    exit 1
fi

BACKUP_TYPE="$1"
shift

PODMAN_ARGS=()
if [ "$EUID" -eq 0 ]; then
    PODMAN_ARGS=(--uidmap "0:$(id -u pod_user):1" --gidmap "0:$(id -g pod_user):1")
fi

podman run --rm -i \
    "${PODMAN_ARGS[@]}" \
    --env-file "/etc/atxoft/backup/$BACKUP_TYPE.env" \
    -v restic-cache:/root/.cache/restic \
    -v /var/backup/containers:/backup:z \
    docker.io/restic/restic:latest "$@"
